import 'currency.dart';
import 'date_only.dart';
import 'exchange_rates.dart';
import 'income.dart';

/// Cuánto aportó una moneda al total, ya convertido a CUP.
///
/// Es lo que alimenta el desglose de la pantalla de inicio:
/// `200 USD × 440 = 88 000 CUP`.
class CurrencySubtotal {
  const CurrencySubtotal({
    required this.currency,
    required this.amountCents,
    required this.rateCents,
    required this.cupCents,
  });

  final Currency currency;

  /// Total en la moneda original, en centésimas.
  final int amountCents;

  /// Centavos de CUP por unidad, la tasa aplicada.
  final int rateCents;

  /// Equivalente en centavos de CUP.
  final int cupCents;
}

/// El resultado completo del cálculo, listo para pintar.
class TitheCalculation {
  const TitheCalculation({
    required this.subtotals,
    required this.grossCupCents,
    required this.titheCupCents,
    required this.proposedCupCents,
    required this.titheBasisPoints,
    required this.rates,
  });

  /// Desglose por moneda, de mayor a menor valor en CUP.
  final List<CurrencySubtotal> subtotals;

  /// Suma de todos los ingresos pendientes, en centavos de CUP.
  final int grossCupCents;

  /// El diezmo exacto, en centavos de CUP.
  final int titheCupCents;

  /// El diezmo redondeado hacia arriba al CUP entero: lo que la app propone
  /// pagar, porque nadie entrega centavos.
  final int proposedCupCents;

  final int titheBasisPoints;
  final ExchangeRates rates;

  bool get isEmpty => grossCupCents == 0;
}

/// Todo el cálculo del diezmo, sin estado y sin dependencias.
///
/// Deliberadamente Dart puro: nada de Flutter, nada de base de datos. Es la
/// única parte de la app donde equivocarse cuesta dinero de verdad, así que
/// tiene que poder probarse entera en milisegundos.
abstract final class TitheCalculator {
  /// Valora los ingresos pendientes de [incomes] con [rates] y aplica el
  /// diezmo.
  ///
  /// [titheBasisPoints] son puntos básicos: 1000 = 10 %.
  ///
  /// Los ingresos ya pagados se ignoran; es la garantía de que un mismo ingreso
  /// nunca se diezma dos veces.
  static TitheCalculation calculate({
    required List<Income> incomes,
    required ExchangeRates rates,
    required int titheBasisPoints,
  }) {
    final amountByCurrency = <Currency, int>{};

    for (final income in incomes) {
      if (!income.isPending) continue;
      for (final line in income.lines) {
        amountByCurrency.update(
          line.currency,
          (previous) => previous + line.amountCents,
          ifAbsent: () => line.amountCents,
        );
      }
    }

    final subtotals = <CurrencySubtotal>[];
    var grossCupCents = 0;

    for (final entry in amountByCurrency.entries) {
      final cupCents = rates.toCupCents(entry.value, entry.key);
      subtotals.add(
        CurrencySubtotal(
          currency: entry.key,
          amountCents: entry.value,
          rateCents: rates.rateFor(entry.key),
          cupCents: cupCents,
        ),
      );
      grossCupCents += cupCents;
    }

    subtotals.sort((a, b) => b.cupCents.compareTo(a.cupCents));

    final titheCupCents = _percentOf(grossCupCents, titheBasisPoints);

    return TitheCalculation(
      subtotals: subtotals,
      grossCupCents: grossCupCents,
      titheCupCents: titheCupCents,
      proposedCupCents: _ceilToWholeCup(titheCupCents),
      titheBasisPoints: titheBasisPoints,
      rates: rates,
    );
  }

  /// Los ingresos que quedarían saldados por un pago hecho en [paymentDate].
  ///
  /// Son los pendientes cuya fecha no es posterior a la del pago. No hay
  /// períodos de calendario: el período es "todo lo que no he pagado todavía",
  /// así que un ingreso registrado tarde con fecha vieja entra igual en el
  /// próximo pago en vez de perderse.
  static List<Income> incomesCoveredBy({
    required List<Income> incomes,
    required DateTime paymentDate,
  }) => incomes
      .where((i) => i.isPending && isOnOrBefore(i.date, paymentDate))
      .toList();

  /// True si el ingreso quedó por detrás de un pago ya hecho, es decir, se
  /// registró tarde. La UI lo marca para que el usuario entienda por qué
  /// aparece algo viejo entre lo pendiente.
  static bool isOverdue(Income income, {required DateTime? lastPaymentDate}) {
    if (lastPaymentDate == null) return false;
    return income.isPending && isStrictlyBefore(income.date, lastPaymentDate);
  }

  /// Todas las monedas que aparecen en los ingresos pendientes y necesitan
  /// tasa. Sirve para avisar antes de pagar si falta alguna.
  static Set<Currency> currenciesNeeded(List<Income> incomes) => {
    for (final income in incomes)
      if (income.isPending)
        for (final line in income.lines)
          if (line.currency != Currency.cup) line.currency,
  };
}

int _percentOf(int cents, int basisPoints) {
  final numerator = cents * basisPoints;
  return (numerator + 5000) ~/ 10000;
}

int _ceilToWholeCup(int cents) {
  final remainder = cents % 100;
  return remainder == 0 ? cents : cents + (100 - remainder);
}
