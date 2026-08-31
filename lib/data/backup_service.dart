import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/currency.dart';
import 'database.dart';

/// Copia de seguridad manual en JSON.
///
/// Los datos viven solo en el teléfono, así que esta es la única forma de no
/// perderlos al cambiar de móvil o al desinstalar. Se hace en JSON legible a
/// propósito: si algún día la app deja de existir, los datos siguen siendo
/// recuperables a mano.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const formatVersion = 1;

  Future<String> export() async {
    final incomes = await _db.select(_db.incomes).get();
    final incomeLines = await _db.select(_db.incomeLines).get();
    final payments = await _db.select(_db.payments).get();
    final offerings = await _db.select(_db.offerings).get();
    final templates = await _db.select(_db.incomeTemplates).get();
    final templateLines = await _db.select(_db.incomeTemplateLines).get();
    final rates = await _db.select(_db.rates).get();
    final settings = await _db.select(_db.settings).get();

    final linesByIncome = <String, List<Map<String, Object?>>>{};
    for (final line in incomeLines) {
      linesByIncome
          .putIfAbsent(line.incomeId, () => [])
          .add({
            'amountCents': line.amountCents,
            'currency': line.currency.code,
            'position': line.position,
          });
    }

    final linesByTemplate = <String, List<Map<String, Object?>>>{};
    for (final line in templateLines) {
      linesByTemplate
          .putIfAbsent(line.templateId, () => [])
          .add({
            'amountCents': line.amountCents,
            'currency': line.currency.code,
            'position': line.position,
          });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'formatVersion': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'incomes': [
        for (final income in incomes)
          {
            'id': income.id,
            'date': income.date.toIso8601String(),
            'concept': income.concept,
            'note': income.note,
            'paymentId': income.paymentId,
            'lines': linesByIncome[income.id] ?? const [],
          },
      ],
      'payments': [
        for (final payment in payments)
          {
            'id': payment.id,
            'date': payment.date.toIso8601String(),
            'ratesUsed': jsonDecode(payment.ratesUsedJson),
            'grossCupCents': payment.grossCupCents,
            'computedCupCents': payment.computedCupCents,
            'actualCupCents': payment.actualCupCents,
            'titheBasisPoints': payment.titheBasisPoints,
            'note': payment.note,
          },
      ],
      'offerings': [
        for (final offering in offerings)
          {
            'id': offering.id,
            'date': offering.date.toIso8601String(),
            'amountCents': offering.amountCents,
            'currency': offering.currency.code,
            'note': offering.note,
          },
      ],
      'templates': [
        for (final template in templates)
          {
            'id': template.id,
            'name': template.name,
            'concept': template.concept,
            'sortOrder': template.sortOrder,
            'lines': linesByTemplate[template.id] ?? const [],
          },
      ],
      'rates': [
        for (final rate in rates)
          {
            'currency': rate.currency.code,
            'rateCents': rate.rateCents,
            'asOf': rate.asOf.toIso8601String(),
            'savedAt': rate.savedAt.toIso8601String(),
            'isManual': rate.isManual,
          },
      ],
      'settings': {for (final setting in settings) setting.key: setting.value},
    });
  }

  /// Reemplaza **todo** el contenido de la base de datos por el del respaldo.
  ///
  /// Es destructivo a propósito: fusionar dos historiales de pagos produciría
  /// duplicados silenciosos, y en una app de dinero eso es peor que perder el
  /// respaldo. Quien lo llama tiene que confirmarlo antes.
  Future<void> import(String json) async {
    final data = jsonDecode(json);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('El archivo no tiene el formato esperado.');
    }

    final version = data['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw FormatException(
        'El respaldo es de una versión más nueva de la app (v$version).',
      );
    }

    await _db.transaction(() async {
      // El orden importa: primero lo que apunta a otras tablas.
      await _db.delete(_db.incomeLines).go();
      await _db.delete(_db.incomes).go();
      await _db.delete(_db.payments).go();
      await _db.delete(_db.offerings).go();
      await _db.delete(_db.incomeTemplateLines).go();
      await _db.delete(_db.incomeTemplates).go();
      await _db.delete(_db.rates).go();
      await _db.delete(_db.settings).go();

      for (final raw in _list(data['payments'])) {
        await _db
            .into(_db.payments)
            .insert(
              PaymentsCompanion.insert(
                id: raw['id'] as String,
                date: DateTime.parse(raw['date'] as String),
                ratesUsedJson: jsonEncode(raw['ratesUsed'] ?? const {}),
                grossCupCents: raw['grossCupCents'] as int,
                computedCupCents: raw['computedCupCents'] as int,
                actualCupCents: raw['actualCupCents'] as int,
                titheBasisPoints: raw['titheBasisPoints'] as int,
                note: Value(raw['note'] as String?),
              ),
            );
      }

      for (final raw in _list(data['incomes'])) {
        final id = raw['id'] as String;
        await _db
            .into(_db.incomes)
            .insert(
              IncomesCompanion.insert(
                id: id,
                date: DateTime.parse(raw['date'] as String),
                concept: Value((raw['concept'] as String?) ?? ''),
                note: Value(raw['note'] as String?),
                paymentId: Value(raw['paymentId'] as String?),
              ),
            );

        for (final line in _list(raw['lines'])) {
          await _db
              .into(_db.incomeLines)
              .insert(
                IncomeLinesCompanion.insert(
                  incomeId: id,
                  amountCents: line['amountCents'] as int,
                  currency: Currency.fromCode(line['currency'] as String),
                  position: Value((line['position'] as int?) ?? 0),
                ),
              );
        }
      }

      for (final raw in _list(data['offerings'])) {
        await _db
            .into(_db.offerings)
            .insert(
              OfferingsCompanion.insert(
                id: raw['id'] as String,
                date: DateTime.parse(raw['date'] as String),
                amountCents: raw['amountCents'] as int,
                currency: Currency.fromCode(raw['currency'] as String),
                note: Value(raw['note'] as String?),
              ),
            );
      }

      for (final raw in _list(data['templates'])) {
        final id = raw['id'] as String;
        await _db
            .into(_db.incomeTemplates)
            .insert(
              IncomeTemplatesCompanion.insert(
                id: id,
                name: raw['name'] as String,
                concept: Value((raw['concept'] as String?) ?? ''),
                sortOrder: Value((raw['sortOrder'] as int?) ?? 0),
              ),
            );

        for (final line in _list(raw['lines'])) {
          await _db
              .into(_db.incomeTemplateLines)
              .insert(
                IncomeTemplateLinesCompanion.insert(
                  templateId: id,
                  amountCents: line['amountCents'] as int,
                  currency: Currency.fromCode(line['currency'] as String),
                  position: Value((line['position'] as int?) ?? 0),
                ),
              );
        }
      }

      for (final raw in _list(data['rates'])) {
        await _db
            .into(_db.rates)
            .insert(
              RatesCompanion.insert(
                currency: Currency.fromCode(raw['currency'] as String),
                rateCents: raw['rateCents'] as int,
                asOf: DateTime.parse(raw['asOf'] as String),
                savedAt: DateTime.parse(raw['savedAt'] as String),
                isManual: Value((raw['isManual'] as bool?) ?? false),
              ),
            );
      }

      final settings = data['settings'];
      if (settings is Map) {
        for (final entry in settings.entries) {
          await _db
              .into(_db.settings)
              .insert(
                SettingsCompanion.insert(
                  key: entry.key.toString(),
                  value: entry.value.toString(),
                ),
              );
        }
      }
    });
  }

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];
}
