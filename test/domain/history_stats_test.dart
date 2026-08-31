import 'package:flutter_test/flutter_test.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/exchange_rates.dart';
import 'package:thites/domain/history_stats.dart';
import 'package:thites/domain/offering.dart';
import 'package:thites/domain/payment.dart';

ExchangeRates get _rates => ExchangeRates(
  asOf: DateTime(2026, 8, 31),
  source: RateSource.api,
  values: {Currency.usd: 67500, Currency.eur: 77000},
);

Payment _pago(
  DateTime date, {
  int actual = 100000,
  int gross = 1000000,
}) => Payment(
  id: 'p-${date.millisecondsSinceEpoch}',
  date: date,
  ratesUsed: const {},
  grossCupCents: gross,
  computedCupCents: actual,
  actualCupCents: actual,
  titheBasisPoints: 1000,
  note: null,
);

Offering _ofrenda(
  DateTime date, {
  int amount = 50000,
  Currency currency = Currency.cup,
}) => Offering(
  id: 'o-${date.millisecondsSinceEpoch}-${currency.code}',
  date: date,
  amountCents: amount,
  currency: currency,
  note: null,
);

void main() {
  group('totales', () {
    test('sin nada, el resumen está vacío', () {
      final stats = HistoryCalculator.compute(
        payments: const [],
        offerings: const [],
        rates: _rates,
      );

      expect(stats.isEmpty, isTrue);
      expect(stats.titheCupCents, 0);
      expect(stats.averagePaymentCupCents, isNull);
      expect(stats.effectiveBasisPoints, isNull);
      expect(stats.byMonth, isEmpty);
    });

    test('suma el diezmo y los ingresos que cubrió', () {
      final stats = HistoryCalculator.compute(
        payments: [
          _pago(DateTime(2026, 8, 5), actual: 100000, gross: 990000),
          _pago(DateTime(2026, 8, 20), actual: 200000, gross: 1980000),
        ],
        offerings: const [],
        rates: _rates,
      );

      expect(stats.titheCupCents, 300000);
      expect(stats.grossCupCents, 2970000);
      expect(stats.paymentCount, 2);
      expect(stats.averagePaymentCupCents, 150000);
    });

    test('la media no revienta con un solo pago', () {
      final stats = HistoryCalculator.compute(
        payments: [_pago(DateTime(2026, 8, 5), actual: 12345)],
        offerings: const [],
        rates: _rates,
      );

      expect(stats.averagePaymentCupCents, 12345);
    });
  });

  group('ofrendas', () {
    test('las de CUP se suman tal cual y no son aproximadas', () {
      final stats = HistoryCalculator.compute(
        payments: const [],
        offerings: [
          _ofrenda(DateTime(2026, 8, 10), amount: 50000),
          _ofrenda(DateTime(2026, 8, 12), amount: 25000),
        ],
        rates: _rates,
      );

      expect(stats.offeringCupCents, 75000);
      expect(stats.offeringCount, 2);
      expect(stats.offeringsAreApproximate, isFalse);
    });

    test('una ofrenda en divisa se convierte y se marca como aproximada', () {
      // Las ofrendas no congelan la tasa como sí hacen los pagos, así que su
      // total en CUP depende de la tasa de hoy y hay que decirlo.
      final stats = HistoryCalculator.compute(
        payments: const [],
        offerings: [
          _ofrenda(DateTime(2026, 8, 10), amount: 1000, currency: Currency.usd),
        ],
        rates: _rates,
      );

      expect(stats.offeringCupCents, 675000); // 10 USD × 675
      expect(stats.offeringsAreApproximate, isTrue);
    });

    test('sin tasa, la ofrenda en divisa se deja fuera del total', () {
      // Contarla como si fueran CUP sería mentir por defecto.
      final stats = HistoryCalculator.compute(
        payments: const [],
        offerings: [
          _ofrenda(DateTime(2026, 8, 10), amount: 1000, currency: Currency.mlc),
        ],
        rates: _rates,
      );

      expect(stats.offeringCupCents, 0);
      expect(stats.offeringCount, 1);
      expect(stats.offeringsAreApproximate, isTrue);
    });
  });

  group('rango', () {
    final pagos = [
      _pago(DateTime(2026, 7, 20), actual: 100000),
      _pago(DateTime(2026, 8, 5), actual: 200000),
      _pago(DateTime(2026, 8, 31), actual: 300000),
      _pago(DateTime(2026, 9, 1), actual: 400000),
    ];

    test('sin límites entra todo', () {
      final stats = HistoryCalculator.compute(
        payments: pagos,
        offerings: const [],
        rates: _rates,
      );

      expect(stats.paymentCount, 4);
    });

    test('los límites son inclusivos por ambos lados', () {
      final stats = HistoryCalculator.compute(
        payments: pagos,
        offerings: const [],
        rates: _rates,
        from: DateTime(2026, 8, 5),
        to: DateTime(2026, 8, 31),
      );

      expect(stats.paymentCount, 2);
      expect(stats.titheCupCents, 500000);
    });

    test('la hora del día no saca a nadie del rango', () {
      final stats = HistoryCalculator.compute(
        payments: [_pago(DateTime(2026, 8, 31, 23, 59), actual: 100)],
        offerings: const [],
        rates: _rates,
        to: DateTime(2026, 8, 31, 0, 0),
      );

      expect(stats.paymentCount, 1);
    });

    test('guarda el primero y el último pago del rango', () {
      final stats = HistoryCalculator.compute(
        payments: pagos,
        offerings: const [],
        rates: _rates,
      );

      expect(stats.firstPayment, DateTime(2026, 7, 20));
      expect(stats.lastPayment, DateTime(2026, 9, 1));
    });
  });

  group('serie mensual', () {
    test('agrupa por mes y sale ordenada de vieja a nueva', () {
      final stats = HistoryCalculator.compute(
        payments: [
          _pago(DateTime(2026, 9, 1), actual: 400000),
          _pago(DateTime(2026, 7, 20), actual: 100000),
          _pago(DateTime(2026, 8, 5), actual: 200000),
          _pago(DateTime(2026, 8, 31), actual: 300000),
        ],
        offerings: const [],
        rates: _rates,
      );

      expect(stats.byMonth.map((m) => m.month), [
        DateTime(2026, 7),
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]);
      expect(stats.byMonth.map((m) => m.titheCupCents), [
        100000,
        500000,
        400000,
      ]);
    });

    test('las ofrendas van en su propia parte de la barra', () {
      final stats = HistoryCalculator.compute(
        payments: [_pago(DateTime(2026, 8, 5), actual: 200000)],
        offerings: [_ofrenda(DateTime(2026, 8, 10), amount: 50000)],
        rates: _rates,
      );

      final agosto = stats.byMonth.single;
      expect(agosto.titheCupCents, 200000);
      expect(agosto.offeringCupCents, 50000);
      expect(agosto.totalCupCents, 250000);
    });

    test('un mes con solo ofrendas también aparece', () {
      final stats = HistoryCalculator.compute(
        payments: const [],
        offerings: [_ofrenda(DateTime(2026, 8, 10), amount: 50000)],
        rates: _rates,
      );

      expect(stats.byMonth.single.month, DateTime(2026, 8));
      expect(stats.byMonth.single.titheCupCents, 0);
    });
  });

  group('porcentaje efectivo', () {
    test('el redondeo hacia arriba lo deja por encima del 10 %', () {
      // Se debía 99.999,00 y se entregaron 100.000,00.
      final stats = HistoryCalculator.compute(
        payments: [_pago(DateTime(2026, 8, 5), actual: 10000000, gross: 99999000)],
        offerings: const [],
        rates: _rates,
      );

      expect(stats.effectiveBasisPoints, 1000);
    });

    test('las ofrendas suben el porcentaje entregado', () {
      final stats = HistoryCalculator.compute(
        payments: [_pago(DateTime(2026, 8, 5), actual: 100000, gross: 1000000)],
        offerings: [_ofrenda(DateTime(2026, 8, 6), amount: 50000)],
        rates: _rates,
      );

      // 1.000 + 500 entregados sobre 10.000 de ingreso = 15 %.
      expect(stats.effectiveBasisPoints, 1500);
      expect(stats.totalGivenCupCents, 150000);
    });
  });
}
