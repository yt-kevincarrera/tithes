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
  Future<File> download(
    AvailableUpdate update, {
    void Function(double progress)? onProgress,
  }) async {
    // Desde Android 13 la notificación de progreso necesita permiso. Se pide
    // aquí y no al arrancar, para pedirlo en el momento en que se entiende para
    // qué es. Si lo deniega la descarga sigue igual, solo que a ciegas.
    final downloader = FileDownloader();
    if (await downloader.permissions.status(PermissionType.notifications) !=
        PermissionStatus.granted) {
      await downloader.permissions.request(PermissionType.notifications);
    }

    final filename = 'diezmo-${update.version}.apk';

    final task = DownloadTask(
      url: update.apkUrl,
      filename: filename,
      // El directorio de caché de la app: no necesita permisos de
      // almacenamiento y el FileProvider del instalador llega ahí.
      baseDirectory: BaseDirectory.temporary,
      updates: Updates.statusAndProgress,
      allowPause: true,
      retries: 2,
    );

    final result = await downloader.download(
      task,
      onProgress: (progress) {
        // Antes de conocer el tamaño el paquete manda valores negativos.
        if (progress >= 0) onProgress?.call(progress);
      },
    );

    switch (result.status) {
      case TaskStatus.complete:
        break;
      case TaskStatus.canceled:
        throw UpdateException('Descarga cancelada.');
      case TaskStatus.notFound:
        throw UpdateException('El APK de esa versión ya no está en GitHub.');
      default:
        throw UpdateException(
          result.exception?.description ?? 'La descarga no pudo terminar.',
        );
    }

    return File(await task.filePath());
  }

  /// Deja configurada la notificación del sistema para las descargas.
  ///
  /// Se llama una vez al arrancar. `tapOpensFile` es lo que permite instalar
  /// desde la notificación sin volver a la app.
  static void configureNotifications() {
    FileDownloader().configureNotification(
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
