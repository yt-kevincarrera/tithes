import 'package:flutter_test/flutter_test.dart';
import 'package:thites/domain/period_label.dart';

void main() {
  group('la quincena que se está cobrando', () {
    test('a mediados de mes se cobra la primera quincena', () {
      // El slip de la primera quincena llega sobre el día 20.
      expect(fortnightLabel(DateTime(2026, 8, 20)), '1–15 ago');
      expect(fortnightLabel(DateTime(2026, 8, 22)), '1–15 ago');
      expect(fortnightLabel(DateTime(2026, 8, 31)), '1–15 ago');
    });

    test('a principios de mes se cobra la segunda del mes anterior', () {
      // El de la segunda llega a principios del mes siguiente.
      expect(fortnightLabel(DateTime(2026, 9, 2)), '16–31 ago');
      expect(fortnightLabel(DateTime(2026, 9, 7)), '16–31 ago');
      expect(fortnightLabel(DateTime(2026, 9, 15)), '16–31 ago');
    });

    test('el día 16 ya cuenta como segunda mitad', () {
      expect(fortnightLabel(DateTime(2026, 8, 16)), '1–15 ago');
      expect(fortnightLabel(DateTime(2026, 8, 15)), '16–31 jul');
    });

    test('respeta los meses de 30 días', () {
      expect(fortnightLabel(DateTime(2026, 7, 3)), '16–30 jun');
    });

    test('febrero, con sus 28 o 29 días', () {
      expect(fortnightLabel(DateTime(2026, 3, 3)), '16–28 feb');
      expect(fortnightLabel(DateTime(2028, 3, 3)), '16–29 feb');
    });

    test('en enero se va al diciembre anterior', () {
      final (start, end) = fortnightBeingPaid(DateTime(2027, 1, 5));

      expect(start, DateTime(2026, 12, 16));
      expect(end, DateTime(2026, 12, 31));
      expect(fortnightLabel(DateTime(2027, 1, 5)), '16–31 dic');
    });
  });

  group('el marcador de la plantilla', () {
    test('se sustituye por la quincena', () {
      expect(
        expandPlaceholders('Salario {quincena}', today: DateTime(2026, 8, 20)),
        'Salario 1–15 ago',
      );
    });

    test('un concepto sin marcador se queda igual', () {
      expect(
        expandPlaceholders('freelance', today: DateTime(2026, 8, 20)),
        'freelance',
      );
    });

    test('un texto vacío sigue vacío', () {
      expect(expandPlaceholders('', today: DateTime(2026, 8, 20)), '');
    });

    test('sustituye todas las veces que aparezca', () {
      expect(
        expandPlaceholders(
          '{quincena} / {quincena}',
          today: DateTime(2026, 8, 20),
        ),
        '1–15 ago / 1–15 ago',
      );
    });
  });

  group('rangos', () {
    test('dentro del mismo mes se dice el mes una vez', () {
      expect(rangeLabel(DateTime(2026, 8, 1), DateTime(2026, 8, 15)), '1–15 ago');
    });

    test('a caballo entre dos meses se dicen los dos', () {
      expect(
        rangeLabel(DateTime(2026, 8, 16), DateTime(2026, 9, 2)),
        '16 ago – 2 sep',
      );
    });
  });
}
