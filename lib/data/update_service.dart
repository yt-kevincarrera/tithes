import 'dart:convert';
import 'dart:io';

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

    final assets = body['assets'];
    final apk = assets is List
        ? assets.whereType<Map<String, dynamic>>().firstWhere(
            (a) => (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
            orElse: () => const {},
          )
        : const <String, dynamic>{};

    final url = apk['browser_download_url'] as String?;
    if (url == null) {
      throw UpdateException('La versión $version no trae ningún APK.');
    }

    return AvailableUpdate(
      version: version,
      notes: (body['body'] as String? ?? '').trim(),
      apkUrl: url,
      sizeBytes: (apk['size'] as num?)?.toInt() ?? 0,
      releaseUrl: body['html_url'] as String? ?? '',
    );
  }

  /// Descarga el APK a [directory] informando del progreso de 0 a 1.
  ///
  /// Se descarga en streaming y no de un tirón: son decenas de megas y en una
  /// conexión lenta hay que poder enseñar cuánto lleva.
  Future<File> download(
    AvailableUpdate update, {
    required Directory directory,
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(update.apkUrl));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw UpdateException(
        'La descarga falló con el código ${response.statusCode}.',
      );
    }

    final file = File('${directory.path}/diezmo-${update.version}.apk');
    await file.parent.create(recursive: true);

    // Se escribe a un temporal y se renombra al final, para que un APK a medias
    // por un corte de conexión nunca llegue al instalador.
    final partial = File('${file.path}.part');
    final sink = partial.openWrite();

    final total = response.contentLength ?? update.sizeBytes;
    var received = 0;

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }

    if (total > 0 && received < total) {
      await partial.delete();
      throw UpdateException('La descarga se cortó antes de terminar.');
    }

    if (file.existsSync()) await file.delete();
    await partial.rename(file.path);
    onProgress?.call(1);
    return file;
  }

  void close() => _client.close();
}
