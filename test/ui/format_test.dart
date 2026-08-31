import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/ui/format.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('parseAmountToCents', () {
    test('un entero simple', () {
      expect(parseAmountToCents('200'), 20000);
    });

    test('con coma decimal, como se escribe aquí', () {
      expect(parseAmountToCents('4873,24'), 487324);
    });

    test('con punto decimal, como lo pone un teclado numérico', () {
      expect(parseAmountToCents('4873.24'), 487324);
    });

    test('un solo decimal se completa a dos', () {
      expect(parseAmountToCents('10,5'), 1050);
    });

    test('con separador de miles y decimales', () {
      expect(parseAmountToCents('1.234,56'), 123456);
      expect(parseAmountToCents('1,234.56'), 123456);
    });

    test('con separador de miles y sin decimales', () {
      // Tres dígitos tras el separador no son centavos: son miles.
      expect(parseAmountToCents('1.234'), 123400);
      expect(parseAmountToCents('12.000'), 1200000);
    });

    test('ignora los espacios', () {
      expect(parseAmountToCents(' 1 200 '), 120000);
    });

    test('empezando por el separador decimal', () {
      expect(parseAmountToCents(',50'), 50);
    });

    test('devuelve null con basura', () {
      expect(parseAmountToCents(''), isNull);
      expect(parseAmountToCents('abc'), isNull);
      expect(parseAmountToCents(','), isNull);
    });
  });

  group('formato', () {
    test('centésimas a texto con decimales', () {
      expect(formatCents(487324), '4.873,24');
    });

    test('la versión compacta se come los centavos redondos', () {
      expect(formatCentsCompact(500000), '5.000');
      expect(formatCentsCompact(487324), '4.873,24');
    });

    test('el dinero lleva su código de moneda', () {
      expect(formatMoney(20000, Currency.usd), '200,00 USD');
      expect(formatMoneyCompact(20000, Currency.usd), '200 USD');
    });

    test('las tasas se ven como se dicen', () {
      expect(formatRate(44000), '440');
      expect(formatRate(44250), '442,50');
    });
  });

  group('ida y vuelta', () {
    test('lo que se muestra en un campo se vuelve a leer igual', () {
      for (final cents in [1, 50, 100, 12345, 500000, 487324]) {
        expect(
          parseAmountToCents(centsToInput(cents)),
          cents,
          reason: 'falló con $cents',
        );
      }
    });
  });

  group('porcentaje', () {
    test('un porcentaje redondo va sin decimales', () {
      expect(formatBasisPoints(1000), '10 %');
      expect(formatBasisPoints(1200), '12 %');
    });

    test('con decimales se usa la coma', () {
      expect(formatBasisPoints(1250), '12,5 %');
      expect(formatBasisPoints(1205), '12,05 %');
    });
  });

  group('fechas relativas', () {
    final hoy = DateTime(2026, 8, 31);

    test('hoy y ayer se dicen con palabras', () {
      expect(formatRelativeDate(hoy, now: hoy), 'hoy');
      expect(formatRelativeDate(DateTime(2026, 8, 30), now: hoy), 'ayer');
    });

    test('dentro de la semana se cuentan los días', () {
      expect(formatRelativeDate(DateTime(2026, 8, 28), now: hoy), 'hace 3 días');
    });

    test('más atrás se pone la fecha', () {
      expect(formatRelativeDate(DateTime(2026, 7, 1), now: hoy), contains('jul'));
    });

    test('de otro año se pone también el año', () {
      expect(formatRelativeDate(DateTime(2025, 7, 1), now: hoy), contains('2025'));
    });

    test('la hora del día no cambia nada', () {
      expect(formatRelativeDate(DateTime(2026, 8, 31, 23, 59), now: hoy), 'hoy');
    });
  });
}
