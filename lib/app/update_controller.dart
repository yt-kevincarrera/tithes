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

enum UpdateStage { idle, checking, available, downloading, installing }

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
  UpdateState build() => const UpdateState();

  /// Busca una versión nueva.
  ///
  /// En [silent] los fallos no se enseñan: al abrir la app sin internet, o con
  /// GitHub caído, no tiene ningún sentido dar un error por algo que el usuario
  /// no ha pedido.
  Future<void> check({bool silent = true}) async {
    if (state.stage == UpdateStage.checking) return;
    state = state.copyWith(stage: UpdateStage.checking, clearError: true);

    try {
      final current = await ref.read(currentVersionProvider.future);
      final update = await ref
          .read(updateServiceProvider)
          .check(current: current);

      state = UpdateState(
        stage: update == null ? UpdateStage.idle : UpdateStage.available,
        available: update,
      );
    } on UpdateException catch (error) {
      state = UpdateState(error: silent ? null : error.message);
    } catch (error) {
      state = UpdateState(error: silent ? null : error.toString());
    }
  }

  /// Descarga el APK y se lo pasa al instalador de Android.
  ///
  /// Android pedirá permiso para instalar de esta fuente la primera vez; eso lo
  /// resuelve el sistema, no la app.
  Future<void> downloadAndInstall() async {
    final update = state.available;
    if (update == null) return;
    if (state.stage == UpdateStage.downloading) return;

    state = state.copyWith(
      stage: UpdateStage.downloading,
      progress: 0,
      clearError: true,
    );

    try {
      final file = await ref
          .read(updateServiceProvider)
          .download(
            update,
            onProgress: (progress) =>
                state = state.copyWith(progress: progress),
          );

      state = state.copyWith(stage: UpdateStage.installing);

      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        state = state.copyWith(
          stage: UpdateStage.available,
          error: 'No se pudo abrir el instalador: ${result.message}',
        );
      }
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

  void dismiss() => state = state.copyWith(dismissed: true);
}

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
