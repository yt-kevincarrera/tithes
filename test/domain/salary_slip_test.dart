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

/// El otro formato que llega: trae un bono y cambia los nombres de algunas
/// deducciones. También real, con las cifras cambiadas.
const _slipConBono = '''
Salary Slip
Kevin Carrera Calzado

Status: Submitted
Total Gross Monthly Salary: \$ 67,250.00
Personal Income Taxes: 4,743.500
Social Security Contribution: 2,975
Payment Rate: 675

Payroll Period
From: 16-07-2026
To: 31-07-2026

Earnings
Salario Quincenal CUP Acumulado V: \$ 33,750
Salario Quincenal CUP: \$ 33,750
Base Impositiva (CUP): \$ 67,250
Salario Banco CUP: \$ 25,956.50
Salario Tropipay USD: \$ 200
Bono: \$ 100

Deductions
Ingresos Personales 2 (D): \$ 4,793.50
Seguridad Social 2 (D): \$ 3,000

Final Pay (CUP): \$ 25,956.50
''';

void main() {
  group('el slip con bono', () {
    test('coge el bono además del salario', () {
      final slip = SalarySlipParser.parse(_slipConBono);

      expect(slip.lines, [
        const IncomeLine(amountCents: 2595650, currency: Currency.cup),
        const IncomeLine(amountCents: 20000, currency: Currency.usd),
        const IncomeLine(amountCents: 10000, currency: Currency.usd),
      ]);
    });

    test(
      'el bono no está dentro del Final Pay, así que tiene que sumarse',
      () {
        // 33.750 − 4.793,50 − 3.000 = 25.956,50, que es exactamente el Final
        // Pay. El bono queda fuera de esa cuenta: ignorarlo sería calcular el
        // diezmo de menos.
        final slip = SalarySlipParser.parse(_slipConBono);
        final cup = slip.lines.firstWhere((l) => l.currency == Currency.cup);

        expect(cup.amountCents, 2595650);
        expect(
          slip.lines.where((l) => l.currency == Currency.usd).length,
          2,
          reason: 'Tropipay y bono son dos cobros distintos',
        );
      },
    );

    test('sigue ignorando los desgloses y la base impositiva', () {
      final montos = SalarySlipParser.parse(
        _slipConBono,
      ).lines.map((l) => l.amountCents).toList();

      expect(montos, isNot(contains(3375000))); // Salario Quincenal
      expect(montos, isNot(contains(6725000))); // Base Impositiva
      expect(montos, isNot(contains(479350))); // Deducción
      expect(montos, hasLength(3));
    });

    test('lee su período, que cruza el fin de mes', () {
      final slip = SalarySlipParser.parse(_slipConBono);

      expect(slip.conceptLabel(), 'Salario 16–31 jul');
      expect(slip.sourceKey, 'slip:2026-07-16_2026-07-31');
    });

    test('un slip sin bono no inventa una línea', () {
      expect(SalarySlipParser.parse(_slip).lines, hasLength(2));
    });

    test('"Bono Navidad" no se confunde con "Bono"', () {
      // El campo tiene que ser exactamente "Bono:". Si algún día aparece otro
      // que empiece igual, mejor ignorarlo que meter un importe equivocado.
      final slip = SalarySlipParser.parse(
        'Final Pay (CUP): \$ 100\nBono Navidad: \$ 5000',
      );

      expect(slip.lines, hasLength(1));
      expect(slip.lines.single.currency, Currency.cup);
    });
  });

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
