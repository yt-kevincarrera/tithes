import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/currency.dart';

/// URL del proxy por defecto. Se puede fijar al compilar:
///
/// ```
/// flutter build apk --dart-define=RATES_ENDPOINT=https://algo.vercel.app/api/rates
/// ```
///
/// y el usuario puede cambiarla desde Ajustes sin recompilar, que es lo que
/// permite tener la app funcionando antes de que el proxy exista.
const kDefaultRatesEndpoint = String.fromEnvironment('RATES_ENDPOINT');

class RatesApiException implements Exception {
  RatesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Lo que devuelve el proxy, ya parseado.
class FetchedRates {
  const FetchedRates({
    required this.values,
    required this.asOf,
    required this.isStale,
  });

  /// Centavos de CUP por unidad de cada moneda.
  final Map<Currency, int> values;
  final DateTime asOf;

  /// True si el proxy no pudo hablar con elTOQUE y sirvió una copia vieja.
  final bool isStale;
}

/// Cliente del proxy de tasas. No sabe nada de elTOQUE: esa complejidad vive en
/// el servidor, y aquí solo llega un JSON ya normalizado.
class RatesApi {
  RatesApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<FetchedRates> fetch(String endpoint) async {
    if (endpoint.trim().isEmpty) {
      throw RatesApiException(
        'Falta la dirección del servidor de tasas. Configúrala en Ajustes.',
      );
    }

    final uri = Uri.tryParse(endpoint.trim());
    if (uri == null || !uri.hasScheme) {
      throw RatesApiException('La dirección del servidor de tasas no es válida.');
    }

    final http.Response response;
    try {
      response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
    } catch (error) {
      throw RatesApiException('No se pudo conectar: $error');
    }

    if (response.statusCode != 200) {
      throw RatesApiException(
        'El servidor de tasas respondió ${response.statusCode}.',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw RatesApiException('El servidor de tasas devolvió algo ilegible.');
    }

    final rawRates = body['rates'];
    if (rawRates is! Map) {
      throw RatesApiException('La respuesta no trae tasas.');
    }

    final values = <Currency, int>{};
    for (final entry in rawRates.entries) {
      final code = entry.key.toString().toUpperCase();
      if (code == Currency.cup.code) continue;
      final value = entry.value;
      if (value is! num) continue;
      try {
        values[Currency.fromCode(code)] = value.round();
      } on ArgumentError {
        // Moneda que la app todavía no maneja. Se ignora en vez de reventar,
        // para que elTOQUE pueda añadir divisas sin romper esta versión.
        continue;
      }
    }

    if (values.isEmpty) {
      throw RatesApiException('La respuesta no trae ninguna moneda conocida.');
    }

    return FetchedRates(
      values: values,
      asOf: _parseDate(body['date']) ?? DateTime.now(),
      isStale: body['stale'] == true,
    );
  }

  void close() => _client.close();
}

DateTime? _parseDate(Object? value) {
  if (value is! String) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}
