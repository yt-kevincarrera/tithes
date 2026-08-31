import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/update_service.dart';
import '../domain/app_version.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService();
  ref.onDispose(service.close);
  return service;
});

/// Versión que está corriendo ahora mismo, leída del propio APK.
final currentVersionProvider = FutureProvider<AppVersion>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion.tryParse(info.version) ?? const AppVersion(0, 0, 0);
});

enum UpdateStage {
  idle,
  checking,
  available,
  downloading,

  /// Descargado y esperando a que el usuario lance el instalador.
  readyToInstall,

  installing,
}

class UpdateState {
  const UpdateState({
    this.stage = UpdateStage.idle,
    this.available,
    this.progress = 0,
    this.error,
    this.dismissed = false,
  });

  final UpdateStage stage;
  final AvailableUpdate? available;
  final double progress;
  final String? error;

  /// El usuario cerró el aviso. No se vuelve a enseñar hasta el próximo
  /// arranque: avisar es útil una vez, insistir es molestar.
  final bool dismissed;

  bool get showBanner => available != null && !dismissed;
  bool get isBusy =>
      stage == UpdateStage.downloading || stage == UpdateStage.installing;

  UpdateState copyWith({
    UpdateStage? stage,
    AvailableUpdate? available,
    double? progress,
    String? error,
    bool clearError = false,
    bool? dismissed,
  }) => UpdateState(
    stage: stage ?? this.stage,
    available: available ?? this.available,
    progress: progress ?? this.progress,
    error: clearError ? null : (error ?? this.error),
    dismissed: dismissed ?? this.dismissed,
  );
}

class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() {
    // Los callbacks del servicio de descargas son globales y sobreviven a que
    // la pantalla se apague. Es lo que mantiene la barra al día sin que la app
    // tenga que estar esperando nada.
    FileDownloader().registerCallbacks(
      taskStatusCallback: _onStatus,
      taskProgressCallback: _onProgress,
    );
    return const UpdateState();
  }

  void _onProgress(TaskProgressUpdate update) {
    if (!_isOurTask(update.task)) return;
    if (update.progress < 0) return;
    state = state.copyWith(
      stage: UpdateStage.downloading,
      progress: update.progress,
    );
  }

  void _onStatus(TaskStatusUpdate update) {
    if (!_isOurTask(update.task)) return;

    switch (update.status) {
      case TaskStatus.complete:
        state = state.copyWith(
          stage: UpdateStage.readyToInstall,
          progress: 1,
          clearError: true,
        );
        // El archivo ya está: se lanza el instalador solo si la app está
        // delante. Si no lo está, queda la notificación, que al tocarla lo
        // abre igual.
        install();
      case TaskStatus.running:
      case TaskStatus.enqueued:
        state = state.copyWith(stage: UpdateStage.downloading);
      case TaskStatus.canceled:
        state = state.copyWith(stage: UpdateStage.available, progress: 0);
      case TaskStatus.notFound:
        state = state.copyWith(
          stage: UpdateStage.available,
          error: 'El APK de esa versión ya no está en GitHub.',
        );
      case TaskStatus.failed:
        state = state.copyWith(
          stage: UpdateStage.available,
          error:
              update.exception?.description ?? 'La descarga no pudo terminar.',
        );
      case TaskStatus.paused:
      case TaskStatus.waitingToRetry:
        break;
    }
  }

  bool _isOurTask(Task task) {
    final version = state.available?.version;
    return version != null && task.taskId == UpdateService.taskIdFor(version);
  }

  /// Busca una versión nueva.
  ///
  /// En [silent] los fallos no se enseñan: al abrir la app sin internet, o con
  /// GitHub caído, no tiene ningún sentido dar un error por algo que el usuario
  /// no ha pedido.
  Future<void> check({bool silent = true}) async {
    if (state.stage == UpdateStage.checking || state.isBusy) return;
    state = state.copyWith(stage: UpdateStage.checking, clearError: true);

    try {
      final current = await ref.read(currentVersionProvider.future);
      final update = await ref
          .read(updateServiceProvider)
          .check(current: current);

      if (update == null) {
        state = const UpdateState();
        return;
      }

      state = UpdateState(stage: UpdateStage.available, available: update);
      await syncWithDownloadService();
    } on UpdateException catch (error) {
      state = UpdateState(error: silent ? null : error.message);
    } catch (error) {
      state = UpdateState(error: silent ? null : error.toString());
    }
  }

  /// Vuelve a preguntarle al servicio de descargas en qué punto está.
  ///
  /// Se llama al volver a la app. Sin esto, una descarga que terminó con la
  /// pantalla apagada seguiría enseñándose a medias, o peor, como un error.
  Future<void> syncWithDownloadService() async {
    final update = state.available;
    if (update == null) return;

    final service = ref.read(updateServiceProvider);

    if (await service.downloadedApk(update) != null) {
      state = state.copyWith(
        stage: UpdateStage.readyToInstall,
        progress: 1,
        clearError: true,
      );
      return;
    }

    final record = await service.recordFor(update);
    if (record == null) return;

    switch (record.status) {
      case TaskStatus.running:
      case TaskStatus.enqueued:
      case TaskStatus.waitingToRetry:
        state = state.copyWith(
          stage: UpdateStage.downloading,
          progress: record.progress.clamp(0, 1),
          clearError: true,
        );
      case TaskStatus.paused:
        state = state.copyWith(
          stage: UpdateStage.downloading,
          progress: record.progress.clamp(0, 1),
        );
      default:
        // Cualquier otra cosa significa que no hay descarga viva; se vuelve a
        // ofrecer el botón en vez de dejar una barra congelada.
        state = state.copyWith(stage: UpdateStage.available, progress: 0);
    }
  }

  /// Empieza a descargar, o instala si ya estaba descargado.
  Future<void> downloadAndInstall() async {
    final update = state.available;
    if (update == null || state.isBusy) return;

    final service = ref.read(updateServiceProvider);

    if (await service.downloadedApk(update) != null) {
      await install();
      return;
    }

    state = state.copyWith(
      stage: UpdateStage.downloading,
      progress: 0,
      clearError: true,
    );

    try {
      await service.startDownload(update);
    } on UpdateException catch (error) {
      state = state.copyWith(
        stage: UpdateStage.available,
        error: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        stage: UpdateStage.available,
        error: error.toString(),
      );
    }
  }

  /// Le pasa el APK descargado al instalador de Android.
  ///
  /// Android pedirá permiso para instalar de esta fuente la primera vez; eso lo
  /// resuelve el sistema, no la app.
  Future<void> install() async {
    final update = state.available;
    if (update == null) return;

    final file = await ref.read(updateServiceProvider).downloadedApk(update);
    if (file == null) {
      state = state.copyWith(
        stage: UpdateStage.available,
        error: 'El archivo descargado ya no está. Vuelve a intentarlo.',
      );
      return;
    }

    state = state.copyWith(stage: UpdateStage.installing, clearError: true);

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type != ResultType.done) {
      state = state.copyWith(
        // Sigue descargado: se puede reintentar sin volver a bajar nada.
        stage: UpdateStage.readyToInstall,
        error: 'No se pudo abrir el instalador: ${result.message}',
      );
    }
  }

  void dismiss() => state = state.copyWith(dismissed: true);
}

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
