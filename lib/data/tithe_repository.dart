import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/currency.dart';
import '../domain/exchange_rates.dart';
import '../domain/income.dart';
import '../domain/income_template.dart';
import '../domain/offering.dart';
import '../domain/payment.dart';
import 'database.dart';
import 'rates_api.dart';

const _uuid = Uuid();

const _kTitheBasisPoints = 'tithe_basis_points';
const _kRatesEndpoint = 'rates_endpoint';
const _kAnnounceIncomes = 'announce_incomes';
const _kTokenExpiresAt = 'token_expires_at';
const _kDefaultTitheBasisPoints = 1000; // 10 %

/// Única puerta entre el dominio y SQLite.
///
/// Traduce filas a entidades y de vuelta, para que ni la UI ni el cálculo
/// sepan que existe Drift.
class TitheRepository {
  TitheRepository(this._db);

  final AppDatabase _db;

  // ---------------------------------------------------------------- ingresos

  Stream<List<Income>> watchPendingIncomes() {
    final query = _db.select(_db.incomes)
      ..where((i) => i.paymentId.isNull())
      ..orderBy([(i) => OrderingTerm.desc(i.date)]);
    return _withLines(query.watch());
  }

  Stream<List<Income>> watchAllIncomes() {
    final query = _db.select(_db.incomes)
      ..orderBy([(i) => OrderingTerm.desc(i.date)]);
    return _withLines(query.watch());
  }

  Stream<List<Income>> watchIncomesOfPayment(String paymentId) {
    final query = _db.select(_db.incomes)
      ..where((i) => i.paymentId.equals(paymentId))
      ..orderBy([(i) => OrderingTerm.desc(i.date)]);
    return _withLines(query.watch());
  }

  /// Resuelve las líneas de cada ingreso en una sola consulta extra en vez de
  /// una por ingreso.
  Stream<List<Income>> _withLines(Stream<List<IncomeRow>> rows) {
    return rows.asyncMap((incomeRows) async {
      if (incomeRows.isEmpty) return <Income>[];

      final ids = incomeRows.map((r) => r.id).toList();
      final lineQuery = _db.select(_db.incomeLines)
        ..where((l) => l.incomeId.isIn(ids))
        ..orderBy([(l) => OrderingTerm.asc(l.position)]);
      final lineRows = await lineQuery.get();

      final linesByIncome = <String, List<IncomeLine>>{};
      for (final line in lineRows) {
        linesByIncome
            .putIfAbsent(line.incomeId, () => [])
            .add(
              IncomeLine(
                amountCents: line.amountCents,
                currency: line.currency,
              ),
            );
      }

      return [
        for (final row in incomeRows)
          Income(
            id: row.id,
            date: row.date,
            concept: row.concept,
            note: row.note,
            paymentId: row.paymentId,
            lines: linesByIncome[row.id] ?? const [],
          ),
      ];
    });
  }

  /// Crea o reemplaza un ingreso junto con sus líneas.
  Future<String> saveIncome({
    String? id,
    required DateTime date,
    required String concept,
    String? note,
    required List<IncomeLine> lines,
    String? sourceKey,
  }) async {
    final incomeId = id ?? _uuid.v4();

    await _db.transaction(() async {
      final existing = await (_db.select(
        _db.incomes,
      )..where((i) => i.id.equals(incomeId))).getSingleOrNull();

      await _db
          .into(_db.incomes)
          .insertOnConflictUpdate(
            IncomesCompanion.insert(
              id: incomeId,
              date: date,
              concept: Value(concept),
              note: Value(note),
              // Editar un ingreso no lo desliga de su pago ni le borra de dónde
              // vino.
              paymentId: Value(existing?.paymentId),
              sourceKey: Value(sourceKey ?? existing?.sourceKey),
            ),
          );

      await (_db.delete(
        _db.incomeLines,
      )..where((l) => l.incomeId.equals(incomeId))).go();

      for (var i = 0; i < lines.length; i++) {
        await _db
            .into(_db.incomeLines)
            .insert(
              IncomeLinesCompanion.insert(
                incomeId: incomeId,
                amountCents: lines[i].amountCents,
                currency: lines[i].currency,
                position: Value(i),
              ),
            );
      }
    });

    return incomeId;
  }

  Future<void> deleteIncome(String id) =>
      (_db.delete(_db.incomes)..where((i) => i.id.equals(id))).go();

  /// El ingreso que ya se importó de una fuente concreta, si existe.
  ///
  /// Es lo que evita que compartir dos veces el mismo slip duplique un salario
  /// entero sin que nadie se entere.
  Future<Income?> incomeBySource(String sourceKey) async {
    final query = _db.select(_db.incomes)
      ..where((i) => i.sourceKey.equals(sourceKey))
      ..limit(1);
    final found = await _withLines(query.watch()).first;
    return found.isEmpty ? null : found.single;
  }

  // -------------------------------------------------------------------- pagos

  Stream<List<Payment>> watchPayments() {
    final query = _db.select(_db.payments)
      ..orderBy([(p) => OrderingTerm.desc(p.date)]);
    return query.watch().map((rows) => rows.map(_toPayment).toList());
  }

  Stream<Payment?> watchLastPayment() {
    final query = _db.select(_db.payments)
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
      ..limit(1);
    return query.watchSingleOrNull().map((r) => r == null ? null : _toPayment(r));
  }

  /// Registra un pago y salda con él los ingresos indicados, en una sola
  /// transacción: o se guarda todo o no se guarda nada. Si esto quedara a
  /// medias, habría ingresos marcados como pagados apuntando a un pago que no
  /// existe.
  Future<String> registerPayment({
    required DateTime date,
    required Map<Currency, int> ratesUsed,
    required int grossCupCents,
    required int computedCupCents,
    required int actualCupCents,
    required int titheBasisPoints,
    String? note,
    required List<String> incomeIds,
  }) async {
    final paymentId = _uuid.v4();

    await _db.transaction(() async {
      await _db
          .into(_db.payments)
          .insert(
            PaymentsCompanion.insert(
              id: paymentId,
              date: date,
              ratesUsedJson: jsonEncode({
                for (final e in ratesUsed.entries) e.key.code: e.value,
              }),
              grossCupCents: grossCupCents,
              computedCupCents: computedCupCents,
              actualCupCents: actualCupCents,
              titheBasisPoints: titheBasisPoints,
              note: Value(note),
            ),
          );

      await (_db.update(_db.incomes)..where((i) => i.id.isIn(incomeIds))).write(
        IncomesCompanion(paymentId: Value(paymentId)),
      );
    });

    return paymentId;
  }

  /// Deshace un pago: lo borra y devuelve sus ingresos al estado pendiente.
  Future<void> undoPayment(String paymentId) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.incomes,
      )..where((i) => i.paymentId.equals(paymentId))).write(
        const IncomesCompanion(paymentId: Value(null)),
      );
      await (_db.delete(
        _db.payments,
      )..where((p) => p.id.equals(paymentId))).go();
    });
  }

  Payment _toPayment(PaymentRow row) {
    final raw = jsonDecode(row.ratesUsedJson) as Map<String, dynamic>;
    return Payment(
      id: row.id,
      date: row.date,
      ratesUsed: {
        for (final entry in raw.entries)
          Currency.fromCode(entry.key): (entry.value as num).round(),
      },
      grossCupCents: row.grossCupCents,
      computedCupCents: row.computedCupCents,
      actualCupCents: row.actualCupCents,
      titheBasisPoints: row.titheBasisPoints,
      note: row.note,
    );
  }

  // ----------------------------------------------------------------- ofrendas

  Stream<List<Offering>> watchOfferings() {
    final query = _db.select(_db.offerings)
      ..orderBy([(o) => OrderingTerm.desc(o.date)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (r) => Offering(
              id: r.id,
              date: r.date,
              amountCents: r.amountCents,
              currency: r.currency,
              note: r.note,
            ),
          )
          .toList(),
    );
  }

  Future<String> saveOffering({
    String? id,
    required DateTime date,
    required int amountCents,
    required Currency currency,
    String? note,
  }) async {
    final offeringId = id ?? _uuid.v4();
    await _db
        .into(_db.offerings)
        .insertOnConflictUpdate(
          OfferingsCompanion.insert(
            id: offeringId,
            date: date,
            amountCents: amountCents,
            currency: currency,
            note: Value(note),
          ),
        );
    return offeringId;
  }

  Future<void> deleteOffering(String id) =>
      (_db.delete(_db.offerings)..where((o) => o.id.equals(id))).go();

  // --------------------------------------------------------------- plantillas

  Stream<List<IncomeTemplate>> watchTemplates() {
    final query = _db.select(_db.incomeTemplates)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return <IncomeTemplate>[];

      final lineQuery = _db.select(_db.incomeTemplateLines)
        ..where((l) => l.templateId.isIn(rows.map((r) => r.id).toList()))
        ..orderBy([(l) => OrderingTerm.asc(l.position)]);
      final lineRows = await lineQuery.get();

      final linesByTemplate = <String, List<IncomeLine>>{};
      for (final line in lineRows) {
        linesByTemplate
            .putIfAbsent(line.templateId, () => [])
            .add(
              IncomeLine(
                amountCents: line.amountCents,
                currency: line.currency,
              ),
            );
      }

      return [
        for (final row in rows)
          IncomeTemplate(
            id: row.id,
            name: row.name,
            concept: row.concept,
            lines: linesByTemplate[row.id] ?? const [],
            sortOrder: row.sortOrder,
          ),
      ];
    });
  }

  Future<String> saveTemplate({
    String? id,
    required String name,
    required String concept,
    required List<IncomeLine> lines,
    int sortOrder = 0,
  }) async {
    final templateId = id ?? _uuid.v4();

    await _db.transaction(() async {
      await _db
          .into(_db.incomeTemplates)
          .insertOnConflictUpdate(
            IncomeTemplatesCompanion.insert(
              id: templateId,
              name: name,
              concept: Value(concept),
              sortOrder: Value(sortOrder),
            ),
          );

      await (_db.delete(
        _db.incomeTemplateLines,
      )..where((l) => l.templateId.equals(templateId))).go();

      for (var i = 0; i < lines.length; i++) {
        await _db
            .into(_db.incomeTemplateLines)
            .insert(
              IncomeTemplateLinesCompanion.insert(
                templateId: templateId,
                amountCents: lines[i].amountCents,
                currency: lines[i].currency,
                position: Value(i),
              ),
            );
      }
    });

    return templateId;
  }

  Future<void> deleteTemplate(String id) => (_db.delete(
    _db.incomeTemplates,
  )..where((t) => t.id.equals(id))).go();

  // ------------------------------------------------------------------- tasas

  /// Las mejores tasas disponibles: lo escrito a mano pisa a lo descargado.
  Stream<ExchangeRates?> watchRates() {
    return _db.select(_db.rates).watch().map(_bestRates);
  }

  Future<ExchangeRates?> currentRates() async =>
      _bestRates(await _db.select(_db.rates).get());

  ExchangeRates? _bestRates(List<RateRow> rows) {
    if (rows.isEmpty) return null;

    // Una fila por moneda: la manual gana si existe.
    final winners = <Currency, RateRow>{};
    for (final row in rows) {
      final current = winners[row.currency];
      if (current == null || (row.isManual && !current.isManual)) {
        winners[row.currency] = row;
      }
    }

    // Se muestra la fecha de la tasa más vieja de las que se están usando: es
    // la que determina cuán desactualizado está el cálculo.
    final asOf = winners.values
        .map((r) => r.asOf)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    return ExchangeRates(
      asOf: asOf,
      source: winners.values.any((r) => r.isManual)
          ? RateSource.manual
          : RateSource.cache,
      values: {
        for (final entry in winners.entries) entry.key: entry.value.rateCents,
      },
    );
  }

  Future<void> saveDownloadedRates({
    required Map<Currency, int> values,
    required DateTime asOf,
  }) async {
    final now = DateTime.now();
    await _db.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _db.rates,
          RatesCompanion.insert(
            currency: entry.key,
            rateCents: entry.value,
            asOf: asOf,
            savedAt: now,
            isManual: const Value(false),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> saveManualRate({
    required Currency currency,
    required int rateCents,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.rates)
        .insert(
          RatesCompanion.insert(
            currency: currency,
            rateCents: rateCents,
            asOf: now,
            savedAt: now,
            isManual: const Value(true),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> clearManualRate(Currency currency) => (_db.delete(
    _db.rates,
  )..where((r) => r.currency.equals(currency.code) & r.isManual.equals(true)))
      .go();

  Future<Set<Currency>> manualCurrencies() async {
    final rows = await (_db.select(
      _db.rates,
    )..where((r) => r.isManual.equals(true))).get();
    return rows.map((r) => r.currency).toSet();
  }

  // ----------------------------------------------------------------- ajustes

  Stream<int> watchTitheBasisPoints() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_kTitheBasisPoints));
    return query.watchSingleOrNull().map(
      (row) => row == null
          ? _kDefaultTitheBasisPoints
          : int.tryParse(row.value) ?? _kDefaultTitheBasisPoints,
    );
  }

  Future<void> setTitheBasisPoints(int basisPoints) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: _kTitheBasisPoints,
          value: basisPoints.toString(),
        ),
      );

  /// Dirección del proxy de tasas.
  ///
  /// Es un ajuste y no una constante compilada para que la app pueda usarse
  /// antes de que el proxy exista, y para poder moverlo de sitio sin
  /// reinstalar el APK.
  Stream<String> watchRatesEndpoint() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_kRatesEndpoint));
    return query.watchSingleOrNull().map(
      (row) => row?.value ?? kDefaultRatesEndpoint,
    );
  }

  Future<String> ratesEndpoint() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_kRatesEndpoint))).getSingleOrNull();
    return row?.value ?? kDefaultRatesEndpoint;
  }

  Future<void> setRatesEndpoint(String endpoint) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: _kRatesEndpoint, value: endpoint.trim()),
      );

  /// Si cada ingreso registrado emite una notificación para que otra app de
  /// finanzas la capture. Apagado por defecto: nadie quiere notificaciones que
  /// no ha pedido.
  Stream<bool> watchAnnounceIncomes() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_kAnnounceIncomes));
    return query.watchSingleOrNull().map((row) => row?.value == 'true');
  }

  Future<bool> announceIncomes() async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(_kAnnounceIncomes))).getSingleOrNull();
    return row?.value == 'true';
  }

  Future<void> setAnnounceIncomes(bool enabled) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(
          key: _kAnnounceIncomes,
          value: enabled.toString(),
        ),
      );

  /// Cuándo caduca el token de elTOQUE, según lo último que dijo el proxy.
  Stream<DateTime?> watchTokenExpiry() {
    final query = _db.select(_db.settings)
      ..where((s) => s.key.equals(_kTokenExpiresAt));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : DateTime.tryParse(row.value),
    );
  }

  Future<void> setTokenExpiry(DateTime? expiresAt) async {
    if (expiresAt == null) return;
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: _kTokenExpiresAt,
            value: expiresAt.toIso8601String(),
          ),
        );
  }
}
