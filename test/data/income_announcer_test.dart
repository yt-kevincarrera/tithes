import 'package:flutter_test/flutter_test.dart';
import 'package:thites/data/income_announcer.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/income.dart';

void main() {
  group('agrupar por moneda antes de notificar', () {
    test('el salario y el bono en USD salen como un solo aviso', () {
      // Un slip con bono trae 200 USD de salario y 100 de bono. Notificarlos
      // por separado crearía dos transacciones de la misma nómina en Cashew.
      final merged = IncomeAnnouncer.mergeByCurrency(const [
        IncomeLine(amountCents: 2595650, currency: Currency.cup),
        IncomeLine(amountCents: 20000, currency: Currency.usd),
        IncomeLine(amountCents: 10000, currency: Currency.usd),
      ]);

      expect(merged, hasLength(2));
      expect(
        merged.firstWhere((l) => l.currency == Currency.usd).amountCents,
        30000,
      );
      expect(
        merged.firstWhere((l) => l.currency == Currency.cup).amountCents,
        2595650,
      );
    });

    test('respeta el orden en que aparecen las monedas', () {
      final merged = IncomeAnnouncer.mergeByCurrency(const [
        IncomeLine(amountCents: 100, currency: Currency.usd),
        IncomeLine(amountCents: 200, currency: Currency.cup),
        IncomeLine(amountCents: 300, currency: Currency.usd),
      ]);

      expect(merged.map((l) => l.currency), [Currency.usd, Currency.cup]);
      expect(merged.first.amountCents, 400);
    });

    test('una sola moneda se queda igual', () {
      final merged = IncomeAnnouncer.mergeByCurrency(const [
        IncomeLine(amountCents: 2560650, currency: Currency.cup),
      ]);

      expect(merged, hasLength(1));
      expect(merged.single.amountCents, 2560650);
    });

    test('sin líneas no hay nada que agrupar', () {
      expect(IncomeAnnouncer.mergeByCurrency(const []), isEmpty);
    });

    test('tres monedas distintas siguen siendo tres avisos', () {
      final merged = IncomeAnnouncer.mergeByCurrency(const [
        IncomeLine(amountCents: 100, currency: Currency.cup),
        IncomeLine(amountCents: 200, currency: Currency.usd),
        IncomeLine(amountCents: 300, currency: Currency.eur),
      ]);

      expect(merged, hasLength(3));
    });
  });

  group('el texto del aviso', () {
    test('punto decimal y sin separador de miles', () {
      // Cuanto más pobre el formato, menos se equivoca el extractor de Cashew.
      expect(
        IncomeAnnouncer.preview(2560650, Currency.cup),
        '25606.50 CUP',
      );
    });

    test('los céntimos siempre salen, aunque sean cero', () {
      expect(IncomeAnnouncer.preview(30000, Currency.usd), '300.00 USD');
    });

    test('menos de un peso', () {
      expect(IncomeAnnouncer.preview(5, Currency.cup), '0.05 CUP');
    });
  });
}
