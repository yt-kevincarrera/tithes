import 'dart:convert';
import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:http/http.dart' as http;

import '../domain/app_version.dart';

/// Repositorio del que salen las actualizaciones.
///
/// Es público a propósito: los assets de una release privada exigen token, y un
/// token dentro del APK es un secreto que cualquiera puede extraer.
const kUpdateRepo = String.fromEnvironment(
  'UPDATE_REPO',
  defaultValue: 'yt-kevincarrera/tithes',
);

class UpdateException implements Exception {
  UpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Una versión publicada que es más nueva que la instalada.
class AvailableUpdate {
  const AvailableUpdate({
    required this.version,
    required this.notes,
    required this.apkUrl,
    required this.sizeBytes,
    required this.releaseUrl,
  });

  final AppVersion version;
  final String notes;
  final String apkUrl;
  final int sizeBytes;

  /// La página de la release, por si la descarga directa falla y hay que
  /// abrirla en el navegador.
  final String releaseUrl;
}

/// Busca y descarga actualizaciones desde las releases de GitHub.
///
/// La app se instala fuera de Play Store, así que sin esto habría que ir a
/// buscar el APK a mano cada vez.
class UpdateService {
  UpdateService({http.Client? client, this.repo = kUpdateRepo})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String repo;

  /// Devuelve la actualización disponible, o null si ya está la última.
  ///
  /// Lanza [UpdateException] si algo va mal, para que quien llama decida si
  /// callar (arranque) o avisar (comprobación manual).
  Future<AvailableUpdate?> check({required AppVersion current}) async {
    final uri = Uri.parse('https://api.github.com/repos/$repo/releases/latest');

    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 20));
    } catch (error) {
      throw UpdateException('No se pudo consultar GitHub: $error');
    }

    if (response.statusCode == 404) {
      // Todavía no hay ninguna release publicada.
      return null;
    }
    if (response.statusCode != 200) {
      throw UpdateException('GitHub respondió ${response.statusCode}.');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw UpdateException('GitHub devolvió algo inesperado.');
    }

    if (body['draft'] == true || body['prerelease'] == true) return null;

    final version = AppVersion.tryParse(body['tag_name'] as String?);
    if (version == null || !version.isNewerThan(current)) return null;

    final apk = pickApk(body['assets']);
    final url = apk?['browser_download_url'] as String?;
    if (url == null) {
      throw UpdateException(
        'La versión $version no trae un APK para este teléfono.',
      );
    }

    return AvailableUpdate(
      version: version,
      notes: (body['body'] as String? ?? '').trim(),
      apkUrl: url,
      sizeBytes: (apk?['size'] as num?)?.toInt() ?? 0,
      releaseUrl: body['html_url'] as String? ?? '',
    );
  }

  /// Elige, de los APK de la release, el de la arquitectura del teléfono.
  ///
  /// Las releases publican un APK por arquitectura en vez de uno universal: el
  /// universal pesa el triple porque lleva las tres, y aquí cada mega cuenta.
  /// Descargar el de otra arquitectura no rompe nada —Android se negaría a
  /// instalarlo— pero sería gastar la descarga entera para nada.
  ///
  /// Si no hay ninguno que encaje se coge un APK sin sufijo de arquitectura,
  /// que es como se llama el universal; así una release antigua sigue pudiendo
  /// instalarse.
  static Map<String, dynamic>? pickApk(Object? assets, {String? abi}) {
    if (assets is! List) return null;

    final apks = assets
        .whereType<Map<String, dynamic>>()
        .where((a) => _nameOf(a).endsWith('.apk'))
        .toList();
    if (apks.isEmpty) return null;

    final wanted = abi ?? currentAbi;
    if (wanted != null) {
      for (final apk in apks) {
        if (_nameOf(apk).contains(wanted)) return apk;
      }
    }

    // Ningún APK específico: solo vale uno que no lo sea de otra arquitectura.
    for (final apk in apks) {
      final name = _nameOf(apk);
      if (!_knownAbis.any(name.contains)) return apk;
    }

    return null;
  }

  static String _nameOf(Map<String, dynamic> asset) =>
      (asset['name'] as String? ?? '').toLowerCase();

  static const _knownAbis = ['arm64-v8a', 'armeabi-v7a', 'x86_64'];

  /// La arquitectura de este teléfono, con el nombre que usa Android.
  ///
  /// Sale de `dart:ffi`, que ya viene con Dart: añadir un paquete solo para
  /// preguntar esto sería desproporcionado.
  static String? get currentAbi => switch (Abi.current()) {
    Abi.androidArm64 => 'arm64-v8a',
    Abi.androidArm => 'armeabi-v7a',
    Abi.androidX64 => 'x86_64',
    _ => null,
  };

  /// Descarga el APK informando del progreso de 0 a 1.
  ///
  /// Va por el servicio de descargas de Android y no por una petición HTTP
  /// dentro de la app: son decenas de megas sobre una conexión lenta, y una
  /// descarga que vive en el proceso de la app se corta en cuanto se apaga la
  /// pantalla o se cambia de aplicación. Además, así Android enseña su propia
  /// notificación con la barra de progreso y, al terminar, tocarla abre el
  /// instalador aunque la app ya no esté delante.
  /// Identificador estable de la descarga de una versión.
  ///
  /// Que sea estable es lo que permite reencontrar la descarga después de que
  /// Android suspenda o mate la app: al volver se pregunta por este id en vez
  /// de depender de un `Future` que ya no existe.
  static String taskIdFor(AppVersion version) => 'update-$version';

  DownloadTask _taskFor(AvailableUpdate update) => DownloadTask(
    taskId: taskIdFor(update.version),
    url: update.apkUrl,
    filename: 'diezmo-${update.version}.apk',
    // El directorio de caché de la app: no necesita permisos de almacenamiento
    // y el FileProvider del instalador llega ahí.
    baseDirectory: BaseDirectory.temporary,
    updates: Updates.statusAndProgress,
    allowPause: true,
    retries: 2,
  );

  /// Encola la descarga y devuelve al momento.
  ///
  /// **No espera a que termine.** Esperar dentro de la app era justo el fallo:
  /// el servicio de Android sigue descargando cuando la pantalla se apaga, pero
  /// la espera vivía en el proceso de la app y moría con él, así que al volver
  /// aparecía un error aunque el archivo estuviera entero. Ahora el progreso
  /// llega por los callbacks y, si el proceso muere, el estado se recupera con
  /// [recordFor].
  Future<void> startDownload(AvailableUpdate update) async {
    // Desde Android 13 la notificación de progreso necesita permiso. Se pide
    // aquí y no al arrancar, para pedirlo cuando se entiende para qué es. Si lo
    // deniega, la descarga sigue igual: solo que a ciegas.
    final downloader = FileDownloader();
    if (await downloader.permissions.status(PermissionType.notifications) !=
        PermissionStatus.granted) {
      await downloader.permissions.request(PermissionType.notifications);
    }

    final enqueued = await downloader.enqueue(_taskFor(update));
    if (!enqueued) {
      throw UpdateException('No se pudo poner la descarga en cola.');
    }
  }

  /// Lo que el servicio de descargas sabe de esa versión, si sabe algo.
  Future<TaskRecord?> recordFor(AvailableUpdate update) =>
      FileDownloader().database.recordForId(taskIdFor(update.version));

  /// El APK de esa versión, si ya está descargado entero.
  ///
  /// El paquete escribe a un temporal y renombra al terminar, así que si el
  /// archivo final existe es que la descarga acabó bien.
  Future<File?> downloadedApk(AvailableUpdate update) async {
    final file = File(await _taskFor(update).filePath());
    return file.existsSync() ? file : null;
  }

  Future<void> cancelDownload(AvailableUpdate update) =>
      FileDownloader().cancelTaskWithId(taskIdFor(update.version));

  /// Deja el servicio de descargas listo. Se llama una vez al arrancar.
  ///
  /// `trackTasks` es lo que guarda el estado de cada descarga en disco, y sin
  /// eso no habría forma de saber, al volver a la app, que la de antes terminó.
  /// `tapOpensFile` permite instalar desde la notificación sin abrir la app.
  static Future<void> configureDownloads() async {
    final downloader = FileDownloader();

    await downloader.trackTasks();

    downloader.configureNotification(
      running: const TaskNotification(
        'Descargando la actualización',
        '{filename} · {progress}',
      ),
      complete: const TaskNotification(
        'Actualización lista',
        'Toca para instalar',
      ),
      error: const TaskNotification(
        'La descarga falló',
        'Vuelve a intentarlo desde Ajustes',
      ),
      paused: const TaskNotification('Descarga en pausa', '{filename}'),
      progressBar: true,
      tapOpensFile: true,
    );
  }

  void close() => _client.close();
}
