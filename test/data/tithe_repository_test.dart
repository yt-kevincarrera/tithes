
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thites/data/database.dart';
import 'package:thites/data/tithe_repository.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/exchange_rates.dart';
import 'package:thites/domain/income.dart';

void main() {
  late AppDatabase db;
  late TitheRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TitheRepository(db);
  });

  tearDown(() => db.close());

  group('ingresos', () {
    test('guarda un ingreso con varias líneas y lo devuelve entero', () async {
      await repo.saveIncome(
        date: DateTime(2026, 8, 15),
        concept: 'salario',
        lines: const [
          IncomeLine(amountCents: 20000, currency: Currency.usd),
          IncomeLine(amountCents: 500000, currency: Currency.cup),
        ],
      );

      final pending = await repo.watchPendingIncomes().first;

      expect(pending, hasLength(1));
      expect(pending.single.concept, 'salario');
      expect(pending.single.lines, [
        const IncomeLine(amountCents: 20000, currency: Currency.usd),
        const IncomeLine(amountCents: 500000, currency: Currency.cup),
      ]);
    });

    test('conserva el orden de las líneas', () async {
      await repo.saveIncome(
        date: DateTime(2026, 8, 15),
        concept: 'mezcla',
        lines: const [
          IncomeLine(amountCents: 1, currency: Currency.mlc),
          IncomeLine(amountCents: 2, currency: Currency.eur),
          IncomeLine(amountCents: 3, currency: Currency.usd),
        ],
      );

      final income = (await repo.watchPendingIncomes().first).single;

      expect(
        income.lines.map((l) => l.currency).toList(),
        [Currency.mlc, Currency.eur, Currency.usd],
      );
    });

    test('editar un ingreso reemplaza sus líneas sin duplicarlas', () async {
      final id = await repo.saveIncome(
        date: DateTime(2026, 8, 15),
        concept: 'salario',
        lines: const [IncomeLine(amountCents: 20000, currency: Currency.usd)],
      );

      await repo.saveIncome(
        id: id,
        date: DateTime(2026, 8, 15),
        concept: 'salario corregido',
        lines: const [IncomeLine(amountCents: 25000, currency: Currency.usd)],
      );

      final income = (await repo.watchPendingIncomes().first).single;

      expect(income.concept, 'salario corregido');
      expect(income.lines, hasLength(1));
      expect(income.lines.single.amountCents, 25000);
    });

    test('borrar un ingreso se lleva sus líneas', () async {
      final id = await repo.saveIncome(
        date: DateTime(2026, 8, 15),
        concept: 'x',
        lines: const [IncomeLine(amountCents: 1, currency: Currency.cup)],
      );

      await repo.deleteIncome(id);

      expect(await repo.watchPendingIncomes().first, isEmpty);
      expect(await db.select(db.incomeLines).get(), isEmpty);
    });
  });

  group('pagos', () {
    Future<String> unIngreso(DateTime date) => repo.saveIncome(
      date: date,
      concept: 'x',
      lines: const [IncomeLine(amountCents: 500000, currency: Currency.cup)],
    );

    test('registrar un pago saca los ingresos de pendientes', () async {
      final a = await unIngreso(DateTime(2026, 8, 10));
      await unIngreso(DateTime(2026, 9, 5));

      await repo.registerPayment(
        date: DateTime(2026, 8, 31),
        ratesUsed: const {Currency.usd: 44000},
        grossCupCents: 500000,
        computedCupCents: 50000,
        actualCupCents: 50000,
        titheBasisPoints: 1000,
        incomeIds: [a],
      );

      final pending = await repo.watchPendingIncomes().first;
      expect(pending, hasLength(1));
      expect(pending.single.date, DateTime(2026, 9, 5));
    });

    test('el pago conserva las tasas usadas', () async {
      final a = await unIngreso(DateTime(2026, 8, 10));

      await repo.registerPayment(
        date: DateTime(2026, 8, 31),
        ratesUsed: const {Currency.usd: 44000, Currency.eur: 48000},
        grossCupCents: 500000,
        computedCupCents: 50000,
        actualCupCents: 50100,
        titheBasisPoints: 1000,
        incomeIds: [a],
      );

      final payment = (await repo.watchPayments().first).single;

      expect(payment.ratesUsed, {Currency.usd: 44000, Currency.eur: 48000});
      expect(payment.computedCupCents, 50000);
      expect(payment.actualCupCents, 50100);
      expect(payment.differenceCupCents, 100);
    });

    test('deshacer un pago devuelve los ingresos a pendientes', () async {
      final a = await unIngreso(DateTime(2026, 8, 10));

      final paymentId = await repo.registerPayment(
        date: DateTime(2026, 8, 31),
        ratesUsed: const {},
        grossCupCents: 500000,
        computedCupCents: 50000,
        actualCupCents: 50000,
        titheBasisPoints: 1000,
        incomeIds: [a],
      );

      await repo.undoPayment(paymentId);

      expect(await repo.watchPendingIncomes().first, hasLength(1));
      expect(await repo.watchPayments().first, isEmpty);
    });

    test('watchLastPayment devuelve el más reciente por fecha', () async {
      await repo.registerPayment(
        date: DateTime(2026, 7, 15),
        ratesUsed: const {},
        grossCupCents: 0,
        computedCupCents: 0,
        actualCupCents: 0,
        titheBasisPoints: 1000,
        incomeIds: const [],
      );
      await repo.registerPayment(
        date: DateTime(2026, 8, 31),
        ratesUsed: const {},
        grossCupCents: 0,
        computedCupCents: 0,
        actualCupCents: 0,
        titheBasisPoints: 1000,
        incomeIds: const [],
      );

      final last = await repo.watchLastPayment().first;
      expect(last!.date, DateTime(2026, 8, 31));
    });
  });

  group('tasas', () {
    test('sin tasas guardadas devuelve null', () async {
      expect(await repo.currentRates(), isNull);
    });

    test('devuelve las tasas descargadas', () async {
      await repo.saveDownloadedRates(
        values: const {Currency.usd: 44000, Currency.eur: 48000},
        asOf: DateTime(2026, 8, 31),
      );

      final rates = (await repo.currentRates())!;

      expect(rates.values, {Currency.usd: 44000, Currency.eur: 48000});
      expect(rates.source, RateSource.cache);
    });

    test('la tasa manual pisa a la descargada', () async {
      await repo.saveDownloadedRates(
        values: const {Currency.usd: 44000},
        asOf: DateTime(2026, 8, 31),
      );
      await repo.saveManualRate(currency: Currency.usd, rateCents: 46000);

      final rates = (await repo.currentRates())!;

      expect(rates.values[Currency.usd], 46000);
      expect(rates.source, RateSource.manual);
    });

    test('borrar la tasa manual devuelve el control a la descargada', () async {
      await repo.saveDownloadedRates(
        values: const {Currency.usd: 44000},
        asOf: DateTime(2026, 8, 31),
      );
      await repo.saveManualRate(currency: Currency.usd, rateCents: 46000);
      await repo.clearManualRate(Currency.usd);

      final rates = (await repo.currentRates())!;

      expect(rates.values[Currency.usd], 44000);
      expect(rates.source, RateSource.cache);
    });

    test('refrescar las descargadas no borra la manual', () async {
      await repo.saveManualRate(currency: Currency.usd, rateCents: 46000);
      await repo.saveDownloadedRates(
        values: const {Currency.usd: 45000},
        asOf: DateTime(2026, 9, 1),
      );

      expect((await repo.currentRates())!.values[Currency.usd], 46000);
      expect(await repo.manualCurrencies(), {Currency.usd});
    });
  });

  group('plantillas', () {
    test('guarda y devuelve una plantilla con sus líneas', () async {
      await repo.saveTemplate(
        name: 'Salario',
        concept: 'salario',
        lines: const [
          IncomeLine(amountCents: 20000, currency: Currency.usd),
          IncomeLine(amountCents: 500000, currency: Currency.cup),
        ],
      );

      final template = (await repo.watchTemplates().first).single;

      expect(template.name, 'Salario');
      expect(template.lines, hasLength(2));
      expect(template.lines.first.currency, Currency.usd);
    });

    test('borrar una plantilla se lleva sus líneas', () async {
      final id = await repo.saveTemplate(
        name: 'Salario',
        concept: 'salario',
        lines: const [IncomeLine(amountCents: 1, currency: Currency.cup)],
      );

      await repo.deleteTemplate(id);

      expect(await repo.watchTemplates().first, isEmpty);
      expect(await db.select(db.incomeTemplateLines).get(), isEmpty);
    });
  });

  group('ajustes', () {
    test('el diezmo por defecto es 10 %', () async {
      expect(await repo.watchTitheBasisPoints().first, 1000);
    });

    test('guarda un porcentaje distinto', () async {
      await repo.setTitheBasisPoints(1250);
      expect(await repo.watchTitheBasisPoints().first, 1250);
    });
  });
}
