import 'currency.dart';

/// De dónde salió una tasa. Determina qué le mostramos al usuario y qué
/// prioridad tiene: lo escrito a mano manda sobre lo descargado.
enum RateSource {
  /// Recién bajada del proxy.
  api,

  /// Guardada localmente de una descarga anterior. Puede estar vieja.
  cache,

  /// Escrita a mano por el usuario.
  manual,
}

class MissingRateException implements Exception {
  MissingRateException(this.currency);

  final Currency currency;

  @override
  String toString() => 'No hay tasa de cambio para ${currency.code}';
}

/// Un juego de tasas de cambio válido en un momento dado.
///
/// Cada valor es **centavos de CUP por una unidad** de la moneda: 44000
/// significa 440,00 CUP por 1 USD. Se guardan como enteros a propósito;
/// `double` acumula errores de céntimos al sumar dinero repetidamente.
class ExchangeRates {
  const ExchangeRates({
    required this.asOf,
    required this.source,
    required this.values,
  });

  /// Fecha a la que corresponden estas tasas, no la fecha en que se
  /// descargaron. Es lo que se le enseña al usuario ("tasa del 28 ago").
  final DateTime asOf;
  final RateSource source;
  final Map<Currency, int> values;

  bool has(Currency currency) =>
      currency == Currency.cup || values.containsKey(currency);

  /// Centavos de CUP por unidad de [currency].
  int rateFor(Currency currency) {
    if (currency == Currency.cup) return 100;
    final rate = values[currency];
    if (rate == null) throw MissingRateException(currency);
    return rate;
  }

  /// Convierte [amountCents] de [currency] a centavos de CUP.
  ///
  /// Redondea al centavo más cercano, con los medios hacia arriba.
  int toCupCents(int amountCents, Currency currency) {
    if (currency == Currency.cup) return amountCents;
    final rate = rateFor(currency);
    return _divideRoundingHalfUp(amountCents * rate, 100);
  }

  ExchangeRates copyWith({
    DateTime? asOf,
    RateSource? source,
    Map<Currency, int>? values,
  }) => ExchangeRates(
    asOf: asOf ?? this.asOf,
    source: source ?? this.source,
    values: values ?? this.values,
  );

  /// Las tasas de [override] pisan a las de este juego. Se usa para que lo que
  /// el usuario escribió a mano gane sobre lo que bajó del proxy.
  ExchangeRates overriddenBy(Map<Currency, int> override) => copyWith(
    values: {...values, ...override},
    source: override.isEmpty ? source : RateSource.manual,
  );
}

int _divideRoundingHalfUp(int numerator, int divisor) {
  if (numerator < 0) {
    return -((-numerator + divisor ~/ 2) ~/ divisor);
  }
  return (numerator + divisor ~/ 2) ~/ divisor;
}
