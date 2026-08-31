import 'package:flutter_test/flutter_test.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/income.dart';
import 'package:thites/domain/salary_slip.dart';

/// Un slip real, con las cifras cambiadas.
const _slip = '''
Salary Slip
Kevin Carrera Calzado

Status: Submitted
Vacation Days to Enjoy During the Period: 1
Personal Income Taxes: 4,693.500
Social Security Contribution: 2,950
Payment Rate: 665

Payroll Period
From: 01-08-2026
To: 15-08-2026

Earnings
Pago  Vacaciones: \$ 20.833
Salario Quincenal CUP Acumulado V: \$ 30,479.167
Salario Quincenal CUP: \$ 33,250
Salario Banco CUP: \$ 25,606.50
Salario Tropipay USD: \$ 200

Deductions
Ingresos Personales 1 (D): \$ 4,693.50
Seguridad Social 1 (D): \$ 2,950

Final Pay (CUP): \$ 25,606.50
''';

void main() {
  group('reconocer un slip', () {
    test('reconoce el slip', () {
      expect(SalarySlipParser.looksLikeSlip(_slip), isTrue);
    });

    test('no confunde cualquier texto con un slip', () {
      expect(SalarySlipParser.looksLikeSlip('hola, ¿comemos?'), isFalse);
      expect(SalarySlipParser.looksLikeSlip(''), isFalse);
    });
  });

  group('parsear el slip', () {
    test('saca solo el cobro real, en sus dos monedas', () {
      final slip = SalarySlipParser.parse(_slip);

      expect(slip.lines, [
        const IncomeLine(amountCents: 2560650, currency: Currency.cup),
        const IncomeLine(amountCents: 20000, currency: Currency.usd),
      ]);
    });

    test(
      'ignora los desgloses y las deducciones, que ya están dentro del '
      'Final Pay',
      () {
        final slip = SalarySlipParser.parse(_slip);

        // 33.250 (Salario Quincenal), 30.479,17 (Acumulado) y las deducciones
        // no pueden aparecer: sumarlas contaría el mismo dinero dos veces.
        final montos = slip.lines.map((l) => l.amountCents).toList();
        expect(montos, isNot(contains(3325000)));
        expect(montos, isNot(contains(3047917)));
        expect(montos, isNot(contains(469350)));
        expect(slip.lines, hasLength(2));
      },
    );

    test('lee el período', () {
      final slip = SalarySlipParser.parse(_slip);

      expect(slip.periodStart, DateTime(2026, 8, 1));
      expect(slip.periodEnd, DateTime(2026, 8, 15));
    });

    test('el período va en el concepto, no en la fecha del ingreso', () {
      // La fecha del ingreso es el día en que llega el slip. Fecharlo al cierre
      // de la quincena haría que un slip que llega con retraso entrara marcado
      // como atrasado si entre medias se pagó el diezmo.
      expect(SalarySlipParser.parse(_slip).conceptLabel(), 'Salario 1–15 ago');
    });

    test('un período a caballo entre dos meses se dice entero', () {
      final slip = SalarySlipParser.parse(
        'From: 16-08-2026\nTo: 02-09-2026\nFinal Pay (CUP): 100',
      );
      expect(slip.conceptLabel(), 'Salario 16 ago – 2 sep');
    });

    test('sin período legible el concepto es genérico y no hay clave', () {
      final slip = SalarySlipParser.parse('Final Pay (CUP): \$ 100');

      expect(slip.periodEnd, isNull);
      expect(slip.conceptLabel(), 'Salario');
      expect(slip.sourceKey, isNull);
    });

    test('la clave identifica el período, no el día de importación', () {
      expect(
        SalarySlipParser.parse(_slip).sourceKey,
        'slip:2026-08-01_2026-08-15',
      );
    });

    test('un texto sin montos no da líneas', () {
      expect(SalarySlipParser.parse('Salary Slip\nStatus: Submitted').isEmpty,
          isTrue);
    });
  });

  group('los números del slip', () {
    test('coma de miles y punto decimal', () {
      final slip = SalarySlipParser.parse('Final Pay (CUP): \$ 25,606.50');
      expect(slip.lines.single.amountCents, 2560650);
    });

    test('sin decimales', () {
      final slip = SalarySlipParser.parse('Salario Tropipay USD: \$ 200');
      expect(slip.lines.single.amountCents, 20000);
    });

    test('tres decimales se redondean al centavo', () {
      // El slip escribe milésimas en algunos campos. 479.167 -> 479,17.
      final slip = SalarySlipParser.parse('Final Pay (CUP): \$ 30,479.167');
      expect(slip.lines.single.amountCents, 3047917);
    });

    test('millones con varias comas', () {
      final slip = SalarySlipParser.parse('Final Pay (CUP): \$ 1,250,606.50');
      expect(slip.lines.single.amountCents, 125060650);
    });

    test('sin el signo de dólar delante', () {
      final slip = SalarySlipParser.parse('Final Pay (CUP): 25,606.50');
      expect(slip.lines.single.amountCents, 2560650);
    });

    test('un monto en cero no genera línea', () {
      expect(SalarySlipParser.parse('Salario Tropipay USD: \$ 0').isEmpty,
          isTrue);
    });
  });
}
