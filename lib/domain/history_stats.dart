import 'currency.dart';
import 'date_only.dart';
import 'exchange_rates.dart';
import 'offering.dart';
import 'payment.dart';

/// Lo pagado en un mes concreto, para la barra del gráfico.
class MonthlyTotal {
  const MonthlyTotal({
    required this.month,
    required this.titheCupCents,
    required this.offeringCupCents,
  });

  /// Día 1 del mes, como identificador.
  final DateTime month;

  final int titheCupCents;
  final int offeringCupCents;

  int get totalCupCents => titheCupCents + offeringCupCents;
}

/// El resumen de un rango del historial.
class HistoryStats {
  const HistoryStats({
    required this.titheCupCents,
    required this.grossCupCents,
    required this.paymentCount,
    required this.offeringCupCents,
    required this.offeringCount,
    required this.offeringsAreApproximate,
    required this.byMonth,
    required this.firstPayment,
    required this.lastPayment,
  });

  /// Diezmo entregado en el rango.
  final int titheCupCents;

  /// Ingresos que ese diezmo cubrió.
  final int grossCupCents;

  final int paymentCount;

  /// Ofrendas del rango, valoradas en CUP.
  final int offeringCupCents;
  final int offeringCount;

  /// True si alguna ofrenda no era en CUP y hubo que convertirla con las tasas
  /// de hoy. A diferencia de los pagos, las ofrendas no guardan la tasa del
  /// día, así que su total en CUP es una estimación y hay que decirlo.
  final bool offeringsAreApproximate;

  /// Un punto por mes con actividad, del más viejo al más nuevo.
  final List<MonthlyTotal> byMonth;

  final DateTime? firstPayment;
  final DateTime? lastPayment;

  bool get isEmpty => paymentCount == 0 && offeringCount == 0;

  int get totalGivenCupCents => titheCupCents + offeringCupCents;

  /// Lo que se paga de media por pago. Null sin pagos.
  int? get averagePaymentCupCents =>
      paymentCount == 0 ? null : titheCupCents ~/ paymentCount;

  /// Qué porcentaje del ingreso acabó entregado, en puntos básicos.
  ///
  /// No tiene por qué ser exactamente el 10 %: los pagos se redondean hacia
  /// arriba y las ofrendas van encima.
  int? get effectiveBasisPoints => grossCupCents == 0
      ? null
      : (totalGivenCupCents * 10000) ~/ grossCupCents;
}

/// Calcula los números del historial.
///
/// Vive en el dominio y no en la pantalla porque son sumas de dinero: es más
/// fácil equivocarse de lo que parece, y aquí se puede probar sin emulador.
abstract final class HistoryCalculator {
  static HistoryStats compute({
    required List<Payment> payments,
    required List<Offering> offerings,
    required ExchangeRates? rates,
    DateTime? from,
    DateTime? to,
  }) {
    bool inRange(DateTime date) {
      final day = dateOnly(date);
      if (from != null && day.isBefore(dateOnly(from))) return false;
      if (to != null && day.isAfter(dateOnly(to))) return false;
      return true;
    }

    final visiblePayments = payments.where((p) => inRange(p.date)).toList();
    final visibleOfferings = offerings.where((o) => inRange(o.date)).toList();

    var tithe = 0;
    var gross = 0;
    for (final payment in visiblePayments) {
      tithe += payment.actualCupCents;
      gross += payment.grossCupCents;
    }

    var offeringTotal = 0;
    var approximate = false;
    for (final offering in visibleOfferings) {
      if (offering.currency == Currency.cup) {
        offeringTotal += offering.amountCents;
        continue;
      }

      // Sin tasa para esa moneda se deja fuera del total en vez de contarla
      // como si fueran CUP, que sería mentir por defecto.
      if (rates == null || !rates.has(offering.currency)) {
        approximate = true;
        continue;
      }
      offeringTotal += rates.toCupCents(
        offering.amountCents,
        offering.currency,
      );
      approximate = true;
    }

    final months = <DateTime, (int, int)>{};
    for (final payment in visiblePayments) {
      final key = DateTime(payment.date.year, payment.date.month);
      final current = months[key] ?? (0, 0);
      months[key] = (current.$1 + payment.actualCupCents, current.$2);
    }
    for (final offering in visibleOfferings) {
      final key = DateTime(offering.date.year, offering.date.month);
      final current = months[key] ?? (0, 0);
      final cup = offering.currency == Currency.cup
          ? offering.amountCents
          : (rates != null && rates.has(offering.currency))
          ? rates.toCupCents(offering.amountCents, offering.currency)
          : 0;
      months[key] = (current.$1, current.$2 + cup);
    }

    final byMonth =
        months.entries
            .map(
              (e) => MonthlyTotal(
                month: e.key,
                titheCupCents: e.value.$1,
                offeringCupCents: e.value.$2,
              ),
            )
            .toList()
          ..sort((a, b) => a.month.compareTo(b.month));

    final dates = visiblePayments.map((p) => p.date).toList()..sort();

    return HistoryStats(
      titheCupCents: tithe,
      grossCupCents: gross,
      paymentCount: visiblePayments.length,
      offeringCupCents: offeringTotal,
      offeringCount: visibleOfferings.length,
      offeringsAreApproximate: approximate,
      byMonth: byMonth,
      firstPayment: dates.isEmpty ? null : dates.first,
      lastPayment: dates.isEmpty ? null : dates.last,
    );
  }
}
