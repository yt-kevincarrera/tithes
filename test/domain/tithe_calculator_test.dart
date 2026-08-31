import 'package:flutter_test/flutter_test.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/exchange_rates.dart';
import 'package:thites/domain/income.dart';
import 'package:thites/domain/tithe_calculator.dart';

/// Tasas de referencia: 1 USD = 440 CUP, 1 EUR = 480 CUP, 1 MLC = 190 CUP.
ExchangeRates get _rates => ExchangeRates(
  asOf: DateTime(2026, 8, 31),
  source: RateSource.api,
  values: {
    Currency.usd: 44000,
    Currency.eur: 48000,
    Currency.mlc: 19000,
  },
);

Income _income({
  required String id,
  required DateTime date,
  required List<IncomeLine> lines,
  String? paymentId,
}) => Income(
  id: id,
  date: date,
  concept: 'test',
  note: null,
  paymentId: paymentId,
  lines: lines,
);

void main() {
  group('conversión a CUP', () {
    test('CUP se toma tal cual, sin tasa', () {
      final rates = _rates;
      expect(rates.toCupCents(500000, Currency.cup), 500000);
    });

    test('convierte USD a CUP con la tasa dada', () {
      // 200.00 USD × 440 = 88 000.00 CUP
      expect(_rates.toCupCents(20000, Currency.usd), 8800000);
    });

    test('convierte con tasas fraccionarias redondeando al centavo', () {
      final rates = ExchangeRates(
        asOf: DateTime(2026, 8, 31),
        source: RateSource.api,
        values: {Currency.usd: 44250}, // 442.50 CUP por USD
      );
      // 10.33 USD × 442.50 = 4571.025 -> 4571.03 CUP
      expect(rates.toCupCents(1033, Currency.usd), 457103);
    });

    test('lanza si falta la tasa de una moneda usada', () {
      final rates = ExchangeRates(
        asOf: DateTime(2026, 8, 31),
        source: RateSource.api,
        values: const {},
      );
      expect(
        () => rates.toCupCents(20000, Currency.usd),
        throwsA(isA<MissingRateException>()),
      );
    });
  });

  group('cálculo del diezmo pendiente', () {
    test('sin ingresos pendientes la deuda es cero', () {
      final result = TitheCalculator.calculate(
        incomes: const [],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.grossCupCents, 0);
      expect(result.titheCupCents, 0);
      expect(result.proposedCupCents, 0);
      expect(result.subtotals, isEmpty);
    });

    test('un ingreso de una sola moneda', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 500000, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.grossCupCents, 500000); // 5 000 CUP
      expect(result.titheCupCents, 50000); // 500 CUP
    });

    test('un ingreso con varias monedas se suma en un solo total', () {
      // El caso real: salario = 200 USD efectivo + 5 000 CUP tarjeta.
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [
              IncomeLine(amountCents: 20000, currency: Currency.usd),
              IncomeLine(amountCents: 500000, currency: Currency.cup),
            ],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      // 88 000 + 5 000 = 93 000 CUP
      expect(result.grossCupCents, 9300000);
      expect(result.titheCupCents, 930000);
    });

    test('agrupa el desglose por moneda a través de varios ingresos', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [
              IncomeLine(amountCents: 20000, currency: Currency.usd),
              IncomeLine(amountCents: 500000, currency: Currency.cup),
            ],
          ),
          _income(
            id: 'b',
            date: DateTime(2026, 8, 20),
            lines: [
              IncomeLine(amountCents: 5000, currency: Currency.usd),
              IncomeLine(amountCents: 10000, currency: Currency.eur),
            ],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.subtotals.length, 3);

      final usd = result.subtotals.firstWhere((s) => s.currency == Currency.usd);
      expect(usd.amountCents, 25000); // 250 USD
      expect(usd.cupCents, 11000000); // 110 000 CUP

      final eur = result.subtotals.firstWhere((s) => s.currency == Currency.eur);
      expect(eur.amountCents, 10000); // 100 EUR
      expect(eur.cupCents, 4800000); // 48 000 CUP

      final cup = result.subtotals.firstWhere((s) => s.currency == Currency.cup);
      expect(cup.cupCents, 500000);

      expect(result.grossCupCents, 11000000 + 4800000 + 500000);
    });

    test('el desglose sale ordenado por valor en CUP, de mayor a menor', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [
              IncomeLine(amountCents: 10000, currency: Currency.cup),
              IncomeLine(amountCents: 20000, currency: Currency.usd),
              IncomeLine(amountCents: 10000, currency: Currency.mlc),
            ],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(
        result.subtotals.map((s) => s.currency).toList(),
        [Currency.usd, Currency.mlc, Currency.cup],
      );
    });

    test('ignora los ingresos que ya fueron pagados', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 500000, currency: Currency.cup)],
            paymentId: 'pago-1',
          ),
          _income(
            id: 'b',
            date: DateTime(2026, 8, 20),
            lines: [IncomeLine(amountCents: 300000, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.grossCupCents, 300000);
      expect(result.titheCupCents, 30000);
    });

    test('respeta un porcentaje de diezmo distinto del 10 %', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 500000, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1250, // 12,5 %
      );

      expect(result.titheCupCents, 62500); // 625 CUP
    });

    test('redondea el diezmo al centavo, medio hacia arriba', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 12345, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      // 123,45 × 10 % = 12,345 -> 12,35 CUP
      expect(result.titheCupCents, 1235);
    });
  });

  group('monto propuesto', () {
    test('redondea hacia arriba al CUP entero', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 4873240, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.titheCupCents, 487324); // 4 873,24
      expect(result.proposedCupCents, 487400); // 4 874,00
    });

    test('un diezmo ya entero no se infla', () {
      final result = TitheCalculator.calculate(
        incomes: [
          _income(
            id: 'a',
            date: DateTime(2026, 8, 15),
            lines: [IncomeLine(amountCents: 500000, currency: Currency.cup)],
          ),
        ],
        rates: _rates,
        titheBasisPoints: 1000,
      );

      expect(result.titheCupCents, 50000);
      expect(result.proposedCupCents, 50000);
    });
  });

  group('qué ingresos cubre un pago', () {
    final agosto15 = _income(
      id: 'a',
      date: DateTime(2026, 8, 15),
      lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
    );
    final agosto31 = _income(
      id: 'b',
      date: DateTime(2026, 8, 31),
      lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
    );
    final septiembre5 = _income(
      id: 'c',
      date: DateTime(2026, 9, 5),
      lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
    );
    final yaPagado = _income(
      id: 'd',
      date: DateTime(2026, 8, 10),
      lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
      paymentId: 'pago-viejo',
    );

    test('cubre los pendientes con fecha anterior o igual a la del pago', () {
      final cubiertos = TitheCalculator.incomesCoveredBy(
        incomes: [agosto15, agosto31, septiembre5, yaPagado],
        paymentDate: DateTime(2026, 8, 31),
      );

      expect(cubiertos.map((i) => i.id), ['a', 'b']);
    });

    test('un ingreso del mismo día del pago entra, sin importar la hora', () {
      final esaTarde = _income(
        id: 'tarde',
        date: DateTime(2026, 8, 31, 22, 30),
        lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
      );

      final cubiertos = TitheCalculator.incomesCoveredBy(
        incomes: [esaTarde],
        paymentDate: DateTime(2026, 8, 31, 9, 0),
      );

      expect(cubiertos.map((i) => i.id), ['tarde']);
    });

    test('nunca vuelve a cubrir un ingreso ya pagado', () {
      final cubiertos = TitheCalculator.incomesCoveredBy(
        incomes: [yaPagado],
        paymentDate: DateTime(2026, 12, 31),
      );

      expect(cubiertos, isEmpty);
    });

    test(
      'un ingreso registrado tarde, con fecha anterior al último pago, '
      'sigue pendiente y entra en el próximo pago',
      () {
        // Este es el caso que garantiza que nada se pierde: el usuario se
        // acuerda el 5 de septiembre de un ingreso del 20 de agosto, cuando ya
        // pagó el 31 de agosto.
        final olvidado = _income(
          id: 'olvidado',
          date: DateTime(2026, 8, 20),
          lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
        );

        final cubiertos = TitheCalculator.incomesCoveredBy(
          incomes: [olvidado],
          paymentDate: DateTime(2026, 9, 15),
        );

        expect(cubiertos.map((i) => i.id), ['olvidado']);
      },
    );
  });

  group('atrasos', () {
    test('marca como atrasado el ingreso anterior al último pago', () {
      final olvidado = _income(
        id: 'olvidado',
        date: DateTime(2026, 8, 20),
        lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
      );

      expect(
        TitheCalculator.isOverdue(olvidado, lastPaymentDate: DateTime(2026, 8, 31)),
        isTrue,
      );
    });

    test('un ingreso posterior al último pago es normal', () {
      final normal = _income(
        id: 'normal',
        date: DateTime(2026, 9, 2),
        lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
      );

      expect(
        TitheCalculator.isOverdue(normal, lastPaymentDate: DateTime(2026, 8, 31)),
        isFalse,
      );
    });

    test('sin pagos previos nada está atrasado', () {
      final cualquiera = _income(
        id: 'x',
        date: DateTime(2020, 1, 1),
        lines: [IncomeLine(amountCents: 100, currency: Currency.cup)],
      );

      expect(
        TitheCalculator.isOverdue(cualquiera, lastPaymentDate: null),
        isFalse,
      );
    });
  });
}
