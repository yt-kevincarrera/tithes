import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/currency.dart';

part 'database.g.dart';

/// Guarda una [Currency] como su código de tres letras, para que la base de
/// datos siga siendo legible y sobreviva a cambios en el orden del enum.
class CurrencyConverter extends TypeConverter<Currency, String> {
  const CurrencyConverter();

  @override
  Currency fromSql(String fromDb) => Currency.fromCode(fromDb);

  @override
  String toSql(Currency value) => value.code;
}

@DataClassName('IncomeRow')
class Incomes extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get concept => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();

  /// Null mientras el ingreso está pendiente de diezmar.
  TextColumn get paymentId =>
      text().nullable().references(Payments, #id, onDelete: KeyAction.setNull)();

  /// Identifica de dónde salió el ingreso cuando no lo tecleó el usuario, por
  /// ejemplo `slip:2026-08-15` para un slip de nómina importado.
  ///
  /// Es lo que permite avisar de que un slip ya se importó en vez de duplicar
  /// un salario en silencio.
  TextColumn get sourceKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('IncomeLineRow')
class IncomeLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get incomeId =>
      text().references(Incomes, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().map(const CurrencyConverter())();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();

  /// Tasas congeladas en el momento del pago, como JSON `{"USD": 44000}`.
  TextColumn get ratesUsedJson => text()();
  IntColumn get grossCupCents => integer()();
  IntColumn get computedCupCents => integer()();
  IntColumn get actualCupCents => integer()();
  IntColumn get titheBasisPoints => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfferingRow')
class Offerings extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().map(const CurrencyConverter())();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TemplateRow')
class IncomeTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get concept => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TemplateLineRow')
class IncomeTemplateLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get templateId =>
      text().references(IncomeTemplates, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountCents => integer()();
  TextColumn get currency => text().map(const CurrencyConverter())();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Última tasa conocida de cada moneda, venga del proxy o escrita a mano.
///
/// Las dos fuentes conviven en la misma tabla porque la app siempre quiere
/// responder la misma pregunta —"¿cuál es la mejor tasa que tengo para USD?"—
/// y [isManual] decide quién gana.
@DataClassName('RateRow')
class Rates extends Table {
  TextColumn get currency => text().map(const CurrencyConverter())();

  /// Centavos de CUP por una unidad de la moneda.
  IntColumn get rateCents => integer()();

  /// Fecha a la que corresponde la tasa.
  DateTimeColumn get asOf => dateTime()();

  /// Cuándo se guardó.
  DateTimeColumn get savedAt => dateTime()();

  BoolColumn get isManual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {currency, isManual};
}

@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Incomes,
    IncomeLines,
    Payments,
    Offerings,
    IncomeTemplates,
    IncomeTemplateLines,
    Rates,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'thites'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(incomes, incomes.sourceKey);
      }
    },
    beforeOpen: (details) async {
      // Sin esto SQLite ignora las claves foráneas y los borrados en cascada
      // no ocurren.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
