// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratesUsedJsonMeta = const VerificationMeta(
    'ratesUsedJson',
  );
  @override
  late final GeneratedColumn<String> ratesUsedJson = GeneratedColumn<String>(
    'rates_used_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossCupCentsMeta = const VerificationMeta(
    'grossCupCents',
  );
  @override
  late final GeneratedColumn<int> grossCupCents = GeneratedColumn<int>(
    'gross_cup_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedCupCentsMeta = const VerificationMeta(
    'computedCupCents',
  );
  @override
  late final GeneratedColumn<int> computedCupCents = GeneratedColumn<int>(
    'computed_cup_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualCupCentsMeta = const VerificationMeta(
    'actualCupCents',
  );
  @override
  late final GeneratedColumn<int> actualCupCents = GeneratedColumn<int>(
    'actual_cup_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titheBasisPointsMeta = const VerificationMeta(
    'titheBasisPoints',
  );
  @override
  late final GeneratedColumn<int> titheBasisPoints = GeneratedColumn<int>(
    'tithe_basis_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    ratesUsedJson,
    grossCupCents,
    computedCupCents,
    actualCupCents,
    titheBasisPoints,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rates_used_json')) {
      context.handle(
        _ratesUsedJsonMeta,
        ratesUsedJson.isAcceptableOrUnknown(
          data['rates_used_json']!,
          _ratesUsedJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ratesUsedJsonMeta);
    }
    if (data.containsKey('gross_cup_cents')) {
      context.handle(
        _grossCupCentsMeta,
        grossCupCents.isAcceptableOrUnknown(
          data['gross_cup_cents']!,
          _grossCupCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grossCupCentsMeta);
    }
    if (data.containsKey('computed_cup_cents')) {
      context.handle(
        _computedCupCentsMeta,
        computedCupCents.isAcceptableOrUnknown(
          data['computed_cup_cents']!,
          _computedCupCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_computedCupCentsMeta);
    }
    if (data.containsKey('actual_cup_cents')) {
      context.handle(
        _actualCupCentsMeta,
        actualCupCents.isAcceptableOrUnknown(
          data['actual_cup_cents']!,
          _actualCupCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualCupCentsMeta);
    }
    if (data.containsKey('tithe_basis_points')) {
      context.handle(
        _titheBasisPointsMeta,
        titheBasisPoints.isAcceptableOrUnknown(
          data['tithe_basis_points']!,
          _titheBasisPointsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_titheBasisPointsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      ratesUsedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rates_used_json'],
      )!,
      grossCupCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cup_cents'],
      )!,
      computedCupCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computed_cup_cents'],
      )!,
      actualCupCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_cup_cents'],
      )!,
      titheBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tithe_basis_points'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final DateTime date;

  /// Tasas congeladas en el momento del pago, como JSON `{"USD": 44000}`.
  final String ratesUsedJson;
  final int grossCupCents;
  final int computedCupCents;
  final int actualCupCents;
  final int titheBasisPoints;
  final String? note;
  const PaymentRow({
    required this.id,
    required this.date,
    required this.ratesUsedJson,
    required this.grossCupCents,
    required this.computedCupCents,
    required this.actualCupCents,
    required this.titheBasisPoints,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['rates_used_json'] = Variable<String>(ratesUsedJson);
    map['gross_cup_cents'] = Variable<int>(grossCupCents);
    map['computed_cup_cents'] = Variable<int>(computedCupCents);
    map['actual_cup_cents'] = Variable<int>(actualCupCents);
    map['tithe_basis_points'] = Variable<int>(titheBasisPoints);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      date: Value(date),
      ratesUsedJson: Value(ratesUsedJson),
      grossCupCents: Value(grossCupCents),
      computedCupCents: Value(computedCupCents),
      actualCupCents: Value(actualCupCents),
      titheBasisPoints: Value(titheBasisPoints),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      ratesUsedJson: serializer.fromJson<String>(json['ratesUsedJson']),
      grossCupCents: serializer.fromJson<int>(json['grossCupCents']),
      computedCupCents: serializer.fromJson<int>(json['computedCupCents']),
      actualCupCents: serializer.fromJson<int>(json['actualCupCents']),
      titheBasisPoints: serializer.fromJson<int>(json['titheBasisPoints']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'ratesUsedJson': serializer.toJson<String>(ratesUsedJson),
      'grossCupCents': serializer.toJson<int>(grossCupCents),
      'computedCupCents': serializer.toJson<int>(computedCupCents),
      'actualCupCents': serializer.toJson<int>(actualCupCents),
      'titheBasisPoints': serializer.toJson<int>(titheBasisPoints),
      'note': serializer.toJson<String?>(note),
    };
  }

  PaymentRow copyWith({
    String? id,
    DateTime? date,
    String? ratesUsedJson,
    int? grossCupCents,
    int? computedCupCents,
    int? actualCupCents,
    int? titheBasisPoints,
    Value<String?> note = const Value.absent(),
  }) => PaymentRow(
    id: id ?? this.id,
    date: date ?? this.date,
    ratesUsedJson: ratesUsedJson ?? this.ratesUsedJson,
    grossCupCents: grossCupCents ?? this.grossCupCents,
    computedCupCents: computedCupCents ?? this.computedCupCents,
    actualCupCents: actualCupCents ?? this.actualCupCents,
    titheBasisPoints: titheBasisPoints ?? this.titheBasisPoints,
    note: note.present ? note.value : this.note,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      ratesUsedJson: data.ratesUsedJson.present
          ? data.ratesUsedJson.value
          : this.ratesUsedJson,
      grossCupCents: data.grossCupCents.present
          ? data.grossCupCents.value
          : this.grossCupCents,
      computedCupCents: data.computedCupCents.present
          ? data.computedCupCents.value
          : this.computedCupCents,
      actualCupCents: data.actualCupCents.present
          ? data.actualCupCents.value
          : this.actualCupCents,
      titheBasisPoints: data.titheBasisPoints.present
          ? data.titheBasisPoints.value
          : this.titheBasisPoints,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('ratesUsedJson: $ratesUsedJson, ')
          ..write('grossCupCents: $grossCupCents, ')
          ..write('computedCupCents: $computedCupCents, ')
          ..write('actualCupCents: $actualCupCents, ')
          ..write('titheBasisPoints: $titheBasisPoints, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    ratesUsedJson,
    grossCupCents,
    computedCupCents,
    actualCupCents,
    titheBasisPoints,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.ratesUsedJson == this.ratesUsedJson &&
          other.grossCupCents == this.grossCupCents &&
          other.computedCupCents == this.computedCupCents &&
          other.actualCupCents == this.actualCupCents &&
          other.titheBasisPoints == this.titheBasisPoints &&
          other.note == this.note);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> ratesUsedJson;
  final Value<int> grossCupCents;
  final Value<int> computedCupCents;
  final Value<int> actualCupCents;
  final Value<int> titheBasisPoints;
  final Value<String?> note;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.ratesUsedJson = const Value.absent(),
    this.grossCupCents = const Value.absent(),
    this.computedCupCents = const Value.absent(),
    this.actualCupCents = const Value.absent(),
    this.titheBasisPoints = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required DateTime date,
    required String ratesUsedJson,
    required int grossCupCents,
    required int computedCupCents,
    required int actualCupCents,
    required int titheBasisPoints,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       ratesUsedJson = Value(ratesUsedJson),
       grossCupCents = Value(grossCupCents),
       computedCupCents = Value(computedCupCents),
       actualCupCents = Value(actualCupCents),
       titheBasisPoints = Value(titheBasisPoints);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? ratesUsedJson,
    Expression<int>? grossCupCents,
    Expression<int>? computedCupCents,
    Expression<int>? actualCupCents,
    Expression<int>? titheBasisPoints,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (ratesUsedJson != null) 'rates_used_json': ratesUsedJson,
      if (grossCupCents != null) 'gross_cup_cents': grossCupCents,
      if (computedCupCents != null) 'computed_cup_cents': computedCupCents,
      if (actualCupCents != null) 'actual_cup_cents': actualCupCents,
      if (titheBasisPoints != null) 'tithe_basis_points': titheBasisPoints,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? ratesUsedJson,
    Value<int>? grossCupCents,
    Value<int>? computedCupCents,
    Value<int>? actualCupCents,
    Value<int>? titheBasisPoints,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      ratesUsedJson: ratesUsedJson ?? this.ratesUsedJson,
      grossCupCents: grossCupCents ?? this.grossCupCents,
      computedCupCents: computedCupCents ?? this.computedCupCents,
      actualCupCents: actualCupCents ?? this.actualCupCents,
      titheBasisPoints: titheBasisPoints ?? this.titheBasisPoints,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (ratesUsedJson.present) {
      map['rates_used_json'] = Variable<String>(ratesUsedJson.value);
    }
    if (grossCupCents.present) {
      map['gross_cup_cents'] = Variable<int>(grossCupCents.value);
    }
    if (computedCupCents.present) {
      map['computed_cup_cents'] = Variable<int>(computedCupCents.value);
    }
    if (actualCupCents.present) {
      map['actual_cup_cents'] = Variable<int>(actualCupCents.value);
    }
    if (titheBasisPoints.present) {
      map['tithe_basis_points'] = Variable<int>(titheBasisPoints.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('ratesUsedJson: $ratesUsedJson, ')
          ..write('grossCupCents: $grossCupCents, ')
          ..write('computedCupCents: $computedCupCents, ')
          ..write('actualCupCents: $actualCupCents, ')
          ..write('titheBasisPoints: $titheBasisPoints, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomesTable extends Incomes with TableInfo<$IncomesTable, IncomeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<String> paymentId = GeneratedColumn<String>(
    'payment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payments (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, concept, note, paymentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'incomes';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_id'],
      ),
    );
  }

  @override
  $IncomesTable createAlias(String alias) {
    return $IncomesTable(attachedDatabase, alias);
  }
}

class IncomeRow extends DataClass implements Insertable<IncomeRow> {
  final String id;
  final DateTime date;
  final String concept;
  final String? note;

  /// Null mientras el ingreso está pendiente de diezmar.
  final String? paymentId;
  const IncomeRow({
    required this.id,
    required this.date,
    required this.concept,
    this.note,
    this.paymentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['concept'] = Variable<String>(concept);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || paymentId != null) {
      map['payment_id'] = Variable<String>(paymentId);
    }
    return map;
  }

  IncomesCompanion toCompanion(bool nullToAbsent) {
    return IncomesCompanion(
      id: Value(id),
      date: Value(date),
      concept: Value(concept),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      paymentId: paymentId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentId),
    );
  }

  factory IncomeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      concept: serializer.fromJson<String>(json['concept']),
      note: serializer.fromJson<String?>(json['note']),
      paymentId: serializer.fromJson<String?>(json['paymentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'concept': serializer.toJson<String>(concept),
      'note': serializer.toJson<String?>(note),
      'paymentId': serializer.toJson<String?>(paymentId),
    };
  }

  IncomeRow copyWith({
    String? id,
    DateTime? date,
    String? concept,
    Value<String?> note = const Value.absent(),
    Value<String?> paymentId = const Value.absent(),
  }) => IncomeRow(
    id: id ?? this.id,
    date: date ?? this.date,
    concept: concept ?? this.concept,
    note: note.present ? note.value : this.note,
    paymentId: paymentId.present ? paymentId.value : this.paymentId,
  );
  IncomeRow copyWithCompanion(IncomesCompanion data) {
    return IncomeRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      concept: data.concept.present ? data.concept.value : this.concept,
      note: data.note.present ? data.note.value : this.note,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('concept: $concept, ')
          ..write('note: $note, ')
          ..write('paymentId: $paymentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, concept, note, paymentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.concept == this.concept &&
          other.note == this.note &&
          other.paymentId == this.paymentId);
}

class IncomesCompanion extends UpdateCompanion<IncomeRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> concept;
  final Value<String?> note;
  final Value<String?> paymentId;
  final Value<int> rowid;
  const IncomesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.concept = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomesCompanion.insert({
    required String id,
    required DateTime date,
    this.concept = const Value.absent(),
    this.note = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date);
  static Insertable<IncomeRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? concept,
    Expression<String>? note,
    Expression<String>? paymentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (concept != null) 'concept': concept,
      if (note != null) 'note': note,
      if (paymentId != null) 'payment_id': paymentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? concept,
    Value<String?>? note,
    Value<String?>? paymentId,
    Value<int>? rowid,
  }) {
    return IncomesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      concept: concept ?? this.concept,
      note: note ?? this.note,
      paymentId: paymentId ?? this.paymentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<String>(paymentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('concept: $concept, ')
          ..write('note: $note, ')
          ..write('paymentId: $paymentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeLinesTable extends IncomeLines
    with TableInfo<$IncomeLinesTable, IncomeLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _incomeIdMeta = const VerificationMeta(
    'incomeId',
  );
  @override
  late final GeneratedColumn<String> incomeId = GeneratedColumn<String>(
    'income_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES incomes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($IncomeLinesTable.$convertercurrency);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    incomeId,
    amountCents,
    currency,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<IncomeLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('income_id')) {
      context.handle(
        _incomeIdMeta,
        incomeId.isAcceptableOrUnknown(data['income_id']!, _incomeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_incomeIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IncomeLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IncomeLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      incomeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}income_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: $IncomeLinesTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $IncomeLinesTable createAlias(String alias) {
    return $IncomeLinesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class IncomeLineRow extends DataClass implements Insertable<IncomeLineRow> {
  final int id;
  final String incomeId;
  final int amountCents;
  final Currency currency;
  final int position;
  const IncomeLineRow({
    required this.id,
    required this.incomeId,
    required this.amountCents,
    required this.currency,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['income_id'] = Variable<String>(incomeId);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['currency'] = Variable<String>(
        $IncomeLinesTable.$convertercurrency.toSql(currency),
      );
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  IncomeLinesCompanion toCompanion(bool nullToAbsent) {
    return IncomeLinesCompanion(
      id: Value(id),
      incomeId: Value(incomeId),
      amountCents: Value(amountCents),
      currency: Value(currency),
      position: Value(position),
    );
  }

  factory IncomeLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IncomeLineRow(
      id: serializer.fromJson<int>(json['id']),
      incomeId: serializer.fromJson<String>(json['incomeId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<Currency>(json['currency']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'incomeId': serializer.toJson<String>(incomeId),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<Currency>(currency),
      'position': serializer.toJson<int>(position),
    };
  }

  IncomeLineRow copyWith({
    int? id,
    String? incomeId,
    int? amountCents,
    Currency? currency,
    int? position,
  }) => IncomeLineRow(
    id: id ?? this.id,
    incomeId: incomeId ?? this.incomeId,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    position: position ?? this.position,
  );
  IncomeLineRow copyWithCompanion(IncomeLinesCompanion data) {
    return IncomeLineRow(
      id: data.id.present ? data.id.value : this.id,
      incomeId: data.incomeId.present ? data.incomeId.value : this.incomeId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IncomeLineRow(')
          ..write('id: $id, ')
          ..write('incomeId: $incomeId, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, incomeId, amountCents, currency, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomeLineRow &&
          other.id == this.id &&
          other.incomeId == this.incomeId &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.position == this.position);
}

class IncomeLinesCompanion extends UpdateCompanion<IncomeLineRow> {
  final Value<int> id;
  final Value<String> incomeId;
  final Value<int> amountCents;
  final Value<Currency> currency;
  final Value<int> position;
  const IncomeLinesCompanion({
    this.id = const Value.absent(),
    this.incomeId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.position = const Value.absent(),
  });
  IncomeLinesCompanion.insert({
    this.id = const Value.absent(),
    required String incomeId,
    required int amountCents,
    required Currency currency,
    this.position = const Value.absent(),
  }) : incomeId = Value(incomeId),
       amountCents = Value(amountCents),
       currency = Value(currency);
  static Insertable<IncomeLineRow> custom({
    Expression<int>? id,
    Expression<String>? incomeId,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (incomeId != null) 'income_id': incomeId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (position != null) 'position': position,
    });
  }

  IncomeLinesCompanion copyWith({
    Value<int>? id,
    Value<String>? incomeId,
    Value<int>? amountCents,
    Value<Currency>? currency,
    Value<int>? position,
  }) {
    return IncomeLinesCompanion(
      id: id ?? this.id,
      incomeId: incomeId ?? this.incomeId,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (incomeId.present) {
      map['income_id'] = Variable<String>(incomeId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $IncomeLinesTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeLinesCompanion(')
          ..write('id: $id, ')
          ..write('incomeId: $incomeId, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $OfferingsTable extends Offerings
    with TableInfo<$OfferingsTable, OfferingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfferingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($OfferingsTable.$convertercurrency);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, amountCents, currency, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offerings';
  @override
  VerificationContext validateIntegrity(
    Insertable<OfferingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfferingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfferingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: $OfferingsTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $OfferingsTable createAlias(String alias) {
    return $OfferingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class OfferingRow extends DataClass implements Insertable<OfferingRow> {
  final String id;
  final DateTime date;
  final int amountCents;
  final Currency currency;
  final String? note;
  const OfferingRow({
    required this.id,
    required this.date,
    required this.amountCents,
    required this.currency,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['currency'] = Variable<String>(
        $OfferingsTable.$convertercurrency.toSql(currency),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  OfferingsCompanion toCompanion(bool nullToAbsent) {
    return OfferingsCompanion(
      id: Value(id),
      date: Value(date),
      amountCents: Value(amountCents),
      currency: Value(currency),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory OfferingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfferingRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<Currency>(json['currency']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<Currency>(currency),
      'note': serializer.toJson<String?>(note),
    };
  }

  OfferingRow copyWith({
    String? id,
    DateTime? date,
    int? amountCents,
    Currency? currency,
    Value<String?> note = const Value.absent(),
  }) => OfferingRow(
    id: id ?? this.id,
    date: date ?? this.date,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    note: note.present ? note.value : this.note,
  );
  OfferingRow copyWithCompanion(OfferingsCompanion data) {
    return OfferingRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfferingRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amountCents, currency, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfferingRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.note == this.note);
}

class OfferingsCompanion extends UpdateCompanion<OfferingRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<int> amountCents;
  final Value<Currency> currency;
  final Value<String?> note;
  final Value<int> rowid;
  const OfferingsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfferingsCompanion.insert({
    required String id,
    required DateTime date,
    required int amountCents,
    required Currency currency,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       amountCents = Value(amountCents),
       currency = Value(currency);
  static Insertable<OfferingRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfferingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<int>? amountCents,
    Value<Currency>? currency,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return OfferingsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $OfferingsTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfferingsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeTemplatesTable extends IncomeTemplates
    with TableInfo<$IncomeTemplatesTable, TemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, concept, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $IncomeTemplatesTable createAlias(String alias) {
    return $IncomeTemplatesTable(attachedDatabase, alias);
  }
}

class TemplateRow extends DataClass implements Insertable<TemplateRow> {
  final String id;
  final String name;
  final String concept;
  final int sortOrder;
  const TemplateRow({
    required this.id,
    required this.name,
    required this.concept,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['concept'] = Variable<String>(concept);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  IncomeTemplatesCompanion toCompanion(bool nullToAbsent) {
    return IncomeTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      concept: Value(concept),
      sortOrder: Value(sortOrder),
    );
  }

  factory TemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      concept: serializer.fromJson<String>(json['concept']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'concept': serializer.toJson<String>(concept),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TemplateRow copyWith({
    String? id,
    String? name,
    String? concept,
    int? sortOrder,
  }) => TemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    concept: concept ?? this.concept,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TemplateRow copyWithCompanion(IncomeTemplatesCompanion data) {
    return TemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      concept: data.concept.present ? data.concept.value : this.concept,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('concept: $concept, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, concept, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.concept == this.concept &&
          other.sortOrder == this.sortOrder);
}

class IncomeTemplatesCompanion extends UpdateCompanion<TemplateRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> concept;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const IncomeTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.concept = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IncomeTemplatesCompanion.insert({
    required String id,
    required String name,
    this.concept = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<TemplateRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? concept,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (concept != null) 'concept': concept,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IncomeTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? concept,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return IncomeTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      concept: concept ?? this.concept,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('concept: $concept, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IncomeTemplateLinesTable extends IncomeTemplateLines
    with TableInfo<$IncomeTemplateLinesTable, TemplateLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IncomeTemplateLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES income_templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($IncomeTemplateLinesTable.$convertercurrency);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    amountCents,
    currency,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_template_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: $IncomeTemplateLinesTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $IncomeTemplateLinesTable createAlias(String alias) {
    return $IncomeTemplateLinesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class TemplateLineRow extends DataClass implements Insertable<TemplateLineRow> {
  final int id;
  final String templateId;
  final int amountCents;
  final Currency currency;
  final int position;
  const TemplateLineRow({
    required this.id,
    required this.templateId,
    required this.amountCents,
    required this.currency,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<String>(templateId);
    map['amount_cents'] = Variable<int>(amountCents);
    {
      map['currency'] = Variable<String>(
        $IncomeTemplateLinesTable.$convertercurrency.toSql(currency),
      );
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  IncomeTemplateLinesCompanion toCompanion(bool nullToAbsent) {
    return IncomeTemplateLinesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      amountCents: Value(amountCents),
      currency: Value(currency),
      position: Value(position),
    );
  }

  factory TemplateLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateLineRow(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<Currency>(json['currency']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<String>(templateId),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<Currency>(currency),
      'position': serializer.toJson<int>(position),
    };
  }

  TemplateLineRow copyWith({
    int? id,
    String? templateId,
    int? amountCents,
    Currency? currency,
    int? position,
  }) => TemplateLineRow(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    position: position ?? this.position,
  );
  TemplateLineRow copyWithCompanion(IncomeTemplateLinesCompanion data) {
    return TemplateLineRow(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateLineRow(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, amountCents, currency, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateLineRow &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.position == this.position);
}

class IncomeTemplateLinesCompanion extends UpdateCompanion<TemplateLineRow> {
  final Value<int> id;
  final Value<String> templateId;
  final Value<int> amountCents;
  final Value<Currency> currency;
  final Value<int> position;
  const IncomeTemplateLinesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.position = const Value.absent(),
  });
  IncomeTemplateLinesCompanion.insert({
    this.id = const Value.absent(),
    required String templateId,
    required int amountCents,
    required Currency currency,
    this.position = const Value.absent(),
  }) : templateId = Value(templateId),
       amountCents = Value(amountCents),
       currency = Value(currency);
  static Insertable<TemplateLineRow> custom({
    Expression<int>? id,
    Expression<String>? templateId,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (position != null) 'position': position,
    });
  }

  IncomeTemplateLinesCompanion copyWith({
    Value<int>? id,
    Value<String>? templateId,
    Value<int>? amountCents,
    Value<Currency>? currency,
    Value<int>? position,
  }) {
    return IncomeTemplateLinesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $IncomeTemplateLinesTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IncomeTemplateLinesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $RatesTable extends Rates with TableInfo<$RatesTable, RateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RatesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($RatesTable.$convertercurrency);
  static const VerificationMeta _rateCentsMeta = const VerificationMeta(
    'rateCents',
  );
  @override
  late final GeneratedColumn<int> rateCents = GeneratedColumn<int>(
    'rate_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _asOfMeta = const VerificationMeta('asOf');
  @override
  late final GeneratedColumn<DateTime> asOf = GeneratedColumn<DateTime>(
    'as_of',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    currency,
    rateCents,
    asOf,
    savedAt,
    isManual,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rate_cents')) {
      context.handle(
        _rateCentsMeta,
        rateCents.isAcceptableOrUnknown(data['rate_cents']!, _rateCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_rateCentsMeta);
    }
    if (data.containsKey('as_of')) {
      context.handle(
        _asOfMeta,
        asOf.isAcceptableOrUnknown(data['as_of']!, _asOfMeta),
      );
    } else if (isInserting) {
      context.missing(_asOfMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {currency, isManual};
  @override
  RateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RateRow(
      currency: $RatesTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      rateCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_cents'],
      )!,
      asOf: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}as_of'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
    );
  }

  @override
  $RatesTable createAlias(String alias) {
    return $RatesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class RateRow extends DataClass implements Insertable<RateRow> {
  final Currency currency;

  /// Centavos de CUP por una unidad de la moneda.
  final int rateCents;

  /// Fecha a la que corresponde la tasa.
  final DateTime asOf;

  /// Cuándo se guardó.
  final DateTime savedAt;
  final bool isManual;
  const RateRow({
    required this.currency,
    required this.rateCents,
    required this.asOf,
    required this.savedAt,
    required this.isManual,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['currency'] = Variable<String>(
        $RatesTable.$convertercurrency.toSql(currency),
      );
    }
    map['rate_cents'] = Variable<int>(rateCents);
    map['as_of'] = Variable<DateTime>(asOf);
    map['saved_at'] = Variable<DateTime>(savedAt);
    map['is_manual'] = Variable<bool>(isManual);
    return map;
  }

  RatesCompanion toCompanion(bool nullToAbsent) {
    return RatesCompanion(
      currency: Value(currency),
      rateCents: Value(rateCents),
      asOf: Value(asOf),
      savedAt: Value(savedAt),
      isManual: Value(isManual),
    );
  }

  factory RateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RateRow(
      currency: serializer.fromJson<Currency>(json['currency']),
      rateCents: serializer.fromJson<int>(json['rateCents']),
      asOf: serializer.fromJson<DateTime>(json['asOf']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
      isManual: serializer.fromJson<bool>(json['isManual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'currency': serializer.toJson<Currency>(currency),
      'rateCents': serializer.toJson<int>(rateCents),
      'asOf': serializer.toJson<DateTime>(asOf),
      'savedAt': serializer.toJson<DateTime>(savedAt),
      'isManual': serializer.toJson<bool>(isManual),
    };
  }

  RateRow copyWith({
    Currency? currency,
    int? rateCents,
    DateTime? asOf,
    DateTime? savedAt,
    bool? isManual,
  }) => RateRow(
    currency: currency ?? this.currency,
    rateCents: rateCents ?? this.rateCents,
    asOf: asOf ?? this.asOf,
    savedAt: savedAt ?? this.savedAt,
    isManual: isManual ?? this.isManual,
  );
  RateRow copyWithCompanion(RatesCompanion data) {
    return RateRow(
      currency: data.currency.present ? data.currency.value : this.currency,
      rateCents: data.rateCents.present ? data.rateCents.value : this.rateCents,
      asOf: data.asOf.present ? data.asOf.value : this.asOf,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RateRow(')
          ..write('currency: $currency, ')
          ..write('rateCents: $rateCents, ')
          ..write('asOf: $asOf, ')
          ..write('savedAt: $savedAt, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(currency, rateCents, asOf, savedAt, isManual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RateRow &&
          other.currency == this.currency &&
          other.rateCents == this.rateCents &&
          other.asOf == this.asOf &&
          other.savedAt == this.savedAt &&
          other.isManual == this.isManual);
}

class RatesCompanion extends UpdateCompanion<RateRow> {
  final Value<Currency> currency;
  final Value<int> rateCents;
  final Value<DateTime> asOf;
  final Value<DateTime> savedAt;
  final Value<bool> isManual;
  final Value<int> rowid;
  const RatesCompanion({
    this.currency = const Value.absent(),
    this.rateCents = const Value.absent(),
    this.asOf = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.isManual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RatesCompanion.insert({
    required Currency currency,
    required int rateCents,
    required DateTime asOf,
    required DateTime savedAt,
    this.isManual = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : currency = Value(currency),
       rateCents = Value(rateCents),
       asOf = Value(asOf),
       savedAt = Value(savedAt);
  static Insertable<RateRow> custom({
    Expression<String>? currency,
    Expression<int>? rateCents,
    Expression<DateTime>? asOf,
    Expression<DateTime>? savedAt,
    Expression<bool>? isManual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (currency != null) 'currency': currency,
      if (rateCents != null) 'rate_cents': rateCents,
      if (asOf != null) 'as_of': asOf,
      if (savedAt != null) 'saved_at': savedAt,
      if (isManual != null) 'is_manual': isManual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RatesCompanion copyWith({
    Value<Currency>? currency,
    Value<int>? rateCents,
    Value<DateTime>? asOf,
    Value<DateTime>? savedAt,
    Value<bool>? isManual,
    Value<int>? rowid,
  }) {
    return RatesCompanion(
      currency: currency ?? this.currency,
      rateCents: rateCents ?? this.rateCents,
      asOf: asOf ?? this.asOf,
      savedAt: savedAt ?? this.savedAt,
      isManual: isManual ?? this.isManual,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (currency.present) {
      map['currency'] = Variable<String>(
        $RatesTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (rateCents.present) {
      map['rate_cents'] = Variable<int>(rateCents.value);
    }
    if (asOf.present) {
      map['as_of'] = Variable<DateTime>(asOf.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RatesCompanion(')
          ..write('currency: $currency, ')
          ..write('rateCents: $rateCents, ')
          ..write('asOf: $asOf, ')
          ..write('savedAt: $savedAt, ')
          ..write('isManual: $isManual, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $IncomesTable incomes = $IncomesTable(this);
  late final $IncomeLinesTable incomeLines = $IncomeLinesTable(this);
  late final $OfferingsTable offerings = $OfferingsTable(this);
  late final $IncomeTemplatesTable incomeTemplates = $IncomeTemplatesTable(
    this,
  );
  late final $IncomeTemplateLinesTable incomeTemplateLines =
      $IncomeTemplateLinesTable(this);
  late final $RatesTable rates = $RatesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    payments,
    incomes,
    incomeLines,
    offerings,
    incomeTemplates,
    incomeTemplateLines,
    rates,
    settings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('incomes', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'incomes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('income_lines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'income_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('income_template_lines', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required DateTime date,
      required String ratesUsedJson,
      required int grossCupCents,
      required int computedCupCents,
      required int actualCupCents,
      required int titheBasisPoints,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> ratesUsedJson,
      Value<int> grossCupCents,
      Value<int> computedCupCents,
      Value<int> actualCupCents,
      Value<int> titheBasisPoints,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$IncomesTable, List<IncomeRow>> _incomesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.incomes,
    aliasName: 'payments__id__incomes__payment_id',
  );

  $$IncomesTableProcessedTableManager get incomesRefs {
    final manager = $$IncomesTableTableManager(
      $_db,
      $_db.incomes,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ratesUsedJson => $composableBuilder(
    column: $table.ratesUsedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCupCents => $composableBuilder(
    column: $table.grossCupCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computedCupCents => $composableBuilder(
    column: $table.computedCupCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualCupCents => $composableBuilder(
    column: $table.actualCupCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get titheBasisPoints => $composableBuilder(
    column: $table.titheBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> incomesRefs(
    Expression<bool> Function($$IncomesTableFilterComposer f) f,
  ) {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ratesUsedJson => $composableBuilder(
    column: $table.ratesUsedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCupCents => $composableBuilder(
    column: $table.grossCupCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computedCupCents => $composableBuilder(
    column: $table.computedCupCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualCupCents => $composableBuilder(
    column: $table.actualCupCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get titheBasisPoints => $composableBuilder(
    column: $table.titheBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get ratesUsedJson => $composableBuilder(
    column: $table.ratesUsedJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grossCupCents => $composableBuilder(
    column: $table.grossCupCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get computedCupCents => $composableBuilder(
    column: $table.computedCupCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualCupCents => $composableBuilder(
    column: $table.actualCupCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get titheBasisPoints => $composableBuilder(
    column: $table.titheBasisPoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> incomesRefs<T extends Object>(
    Expression<T> Function($$IncomesTableAnnotationComposer a) f,
  ) {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool incomesRefs})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> ratesUsedJson = const Value.absent(),
                Value<int> grossCupCents = const Value.absent(),
                Value<int> computedCupCents = const Value.absent(),
                Value<int> actualCupCents = const Value.absent(),
                Value<int> titheBasisPoints = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                date: date,
                ratesUsedJson: ratesUsedJson,
                grossCupCents: grossCupCents,
                computedCupCents: computedCupCents,
                actualCupCents: actualCupCents,
                titheBasisPoints: titheBasisPoints,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String ratesUsedJson,
                required int grossCupCents,
                required int computedCupCents,
                required int actualCupCents,
                required int titheBasisPoints,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                date: date,
                ratesUsedJson: ratesUsedJson,
                grossCupCents: grossCupCents,
                computedCupCents: computedCupCents,
                actualCupCents: actualCupCents,
                titheBasisPoints: titheBasisPoints,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incomesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (incomesRefs) db.incomes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (incomesRefs)
                    await $_getPrefetchedData<
                      PaymentRow,
                      $PaymentsTable,
                      IncomeRow
                    >(
                      currentTable: table,
                      referencedTable: $$PaymentsTableReferences
                          ._incomesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PaymentsTableReferences(db, table, p0).incomesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.paymentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool incomesRefs})
    >;
typedef $$IncomesTableCreateCompanionBuilder =
    IncomesCompanion Function({
      required String id,
      required DateTime date,
      Value<String> concept,
      Value<String?> note,
      Value<String?> paymentId,
      Value<int> rowid,
    });
typedef $$IncomesTableUpdateCompanionBuilder =
    IncomesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> concept,
      Value<String?> note,
      Value<String?> paymentId,
      Value<int> rowid,
    });

final class $$IncomesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomesTable, IncomeRow> {
  $$IncomesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('incomes__payment_id__payments__id');

  $$PaymentsTableProcessedTableManager? get paymentId {
    final $_column = $_itemColumn<String>('payment_id');
    if ($_column == null) return null;
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IncomeLinesTable, List<IncomeLineRow>>
  _incomeLinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.incomeLines,
    aliasName: 'incomes__id__income_lines__income_id',
  );

  $$IncomeLinesTableProcessedTableManager get incomeLinesRefs {
    final manager = $$IncomeLinesTableTableManager(
      $_db,
      $_db.incomeLines,
    ).filter((f) => f.incomeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomeLinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncomesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> incomeLinesRefs(
    Expression<bool> Function($$IncomeLinesTableFilterComposer f) f,
  ) {
    final $$IncomeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomeLines,
      getReferencedColumn: (t) => t.incomeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeLinesTableFilterComposer(
            $db: $db,
            $table: $db.incomeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomesTable> {
  $$IncomesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get concept =>
      $composableBuilder(column: $table.concept, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> incomeLinesRefs<T extends Object>(
    Expression<T> Function($$IncomeLinesTableAnnotationComposer a) f,
  ) {
    final $$IncomeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomeLines,
      getReferencedColumn: (t) => t.incomeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomesTable,
          IncomeRow,
          $$IncomesTableFilterComposer,
          $$IncomesTableOrderingComposer,
          $$IncomesTableAnnotationComposer,
          $$IncomesTableCreateCompanionBuilder,
          $$IncomesTableUpdateCompanionBuilder,
          (IncomeRow, $$IncomesTableReferences),
          IncomeRow,
          PrefetchHooks Function({bool paymentId, bool incomeLinesRefs})
        > {
  $$IncomesTableTableManager(_$AppDatabase db, $IncomesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> concept = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paymentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion(
                id: id,
                date: date,
                concept: concept,
                note: note,
                paymentId: paymentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<String> concept = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> paymentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomesCompanion.insert(
                id: id,
                date: date,
                concept: concept,
                note: note,
                paymentId: paymentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncomesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({paymentId = false, incomeLinesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (incomeLinesRefs) db.incomeLines,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (paymentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paymentId,
                                    referencedTable: $$IncomesTableReferences
                                        ._paymentIdTable(db),
                                    referencedColumn: $$IncomesTableReferences
                                        ._paymentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (incomeLinesRefs)
                        await $_getPrefetchedData<
                          IncomeRow,
                          $IncomesTable,
                          IncomeLineRow
                        >(
                          currentTable: table,
                          referencedTable: $$IncomesTableReferences
                              ._incomeLinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IncomesTableReferences(
                                db,
                                table,
                                p0,
                              ).incomeLinesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.incomeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IncomesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomesTable,
      IncomeRow,
      $$IncomesTableFilterComposer,
      $$IncomesTableOrderingComposer,
      $$IncomesTableAnnotationComposer,
      $$IncomesTableCreateCompanionBuilder,
      $$IncomesTableUpdateCompanionBuilder,
      (IncomeRow, $$IncomesTableReferences),
      IncomeRow,
      PrefetchHooks Function({bool paymentId, bool incomeLinesRefs})
    >;
typedef $$IncomeLinesTableCreateCompanionBuilder =
    IncomeLinesCompanion Function({
      Value<int> id,
      required String incomeId,
      required int amountCents,
      required Currency currency,
      Value<int> position,
    });
typedef $$IncomeLinesTableUpdateCompanionBuilder =
    IncomeLinesCompanion Function({
      Value<int> id,
      Value<String> incomeId,
      Value<int> amountCents,
      Value<Currency> currency,
      Value<int> position,
    });

final class $$IncomeLinesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomeLinesTable, IncomeLineRow> {
  $$IncomeLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IncomesTable _incomeIdTable(_$AppDatabase db) =>
      db.incomes.createAlias('income_lines__income_id__incomes__id');

  $$IncomesTableProcessedTableManager get incomeId {
    final $_column = $_itemColumn<String>('income_id')!;

    final manager = $$IncomesTableTableManager(
      $_db,
      $_db.incomes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_incomeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomeLinesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeLinesTable> {
  $$IncomeLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$IncomesTableFilterComposer get incomeId {
    final $$IncomesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomeId,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableFilterComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeLinesTable> {
  $$IncomeLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$IncomesTableOrderingComposer get incomeId {
    final $$IncomesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomeId,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableOrderingComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeLinesTable> {
  $$IncomeLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$IncomesTableAnnotationComposer get incomeId {
    final $$IncomesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.incomeId,
      referencedTable: $db.incomes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeLinesTable,
          IncomeLineRow,
          $$IncomeLinesTableFilterComposer,
          $$IncomeLinesTableOrderingComposer,
          $$IncomeLinesTableAnnotationComposer,
          $$IncomeLinesTableCreateCompanionBuilder,
          $$IncomeLinesTableUpdateCompanionBuilder,
          (IncomeLineRow, $$IncomeLinesTableReferences),
          IncomeLineRow,
          PrefetchHooks Function({bool incomeId})
        > {
  $$IncomeLinesTableTableManager(_$AppDatabase db, $IncomeLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> incomeId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => IncomeLinesCompanion(
                id: id,
                incomeId: incomeId,
                amountCents: amountCents,
                currency: currency,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String incomeId,
                required int amountCents,
                required Currency currency,
                Value<int> position = const Value.absent(),
              }) => IncomeLinesCompanion.insert(
                id: id,
                incomeId: incomeId,
                amountCents: amountCents,
                currency: currency,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncomeLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incomeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (incomeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.incomeId,
                                referencedTable: $$IncomeLinesTableReferences
                                    ._incomeIdTable(db),
                                referencedColumn: $$IncomeLinesTableReferences
                                    ._incomeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncomeLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeLinesTable,
      IncomeLineRow,
      $$IncomeLinesTableFilterComposer,
      $$IncomeLinesTableOrderingComposer,
      $$IncomeLinesTableAnnotationComposer,
      $$IncomeLinesTableCreateCompanionBuilder,
      $$IncomeLinesTableUpdateCompanionBuilder,
      (IncomeLineRow, $$IncomeLinesTableReferences),
      IncomeLineRow,
      PrefetchHooks Function({bool incomeId})
    >;
typedef $$OfferingsTableCreateCompanionBuilder =
    OfferingsCompanion Function({
      required String id,
      required DateTime date,
      required int amountCents,
      required Currency currency,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$OfferingsTableUpdateCompanionBuilder =
    OfferingsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<int> amountCents,
      Value<Currency> currency,
      Value<String?> note,
      Value<int> rowid,
    });

class $$OfferingsTableFilterComposer
    extends Composer<_$AppDatabase, $OfferingsTable> {
  $$OfferingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OfferingsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfferingsTable> {
  $$OfferingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OfferingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfferingsTable> {
  $$OfferingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$OfferingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OfferingsTable,
          OfferingRow,
          $$OfferingsTableFilterComposer,
          $$OfferingsTableOrderingComposer,
          $$OfferingsTableAnnotationComposer,
          $$OfferingsTableCreateCompanionBuilder,
          $$OfferingsTableUpdateCompanionBuilder,
          (
            OfferingRow,
            BaseReferences<_$AppDatabase, $OfferingsTable, OfferingRow>,
          ),
          OfferingRow,
          PrefetchHooks Function()
        > {
  $$OfferingsTableTableManager(_$AppDatabase db, $OfferingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfferingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfferingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfferingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfferingsCompanion(
                id: id,
                date: date,
                amountCents: amountCents,
                currency: currency,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required int amountCents,
                required Currency currency,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OfferingsCompanion.insert(
                id: id,
                date: date,
                amountCents: amountCents,
                currency: currency,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OfferingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OfferingsTable,
      OfferingRow,
      $$OfferingsTableFilterComposer,
      $$OfferingsTableOrderingComposer,
      $$OfferingsTableAnnotationComposer,
      $$OfferingsTableCreateCompanionBuilder,
      $$OfferingsTableUpdateCompanionBuilder,
      (
        OfferingRow,
        BaseReferences<_$AppDatabase, $OfferingsTable, OfferingRow>,
      ),
      OfferingRow,
      PrefetchHooks Function()
    >;
typedef $$IncomeTemplatesTableCreateCompanionBuilder =
    IncomeTemplatesCompanion Function({
      required String id,
      required String name,
      Value<String> concept,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$IncomeTemplatesTableUpdateCompanionBuilder =
    IncomeTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> concept,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$IncomeTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $IncomeTemplatesTable, TemplateRow> {
  $$IncomeTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$IncomeTemplateLinesTable, List<TemplateLineRow>>
  _incomeTemplateLinesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.incomeTemplateLines,
        aliasName: 'income_templates__id__income_template_lines__template_id',
      );

  $$IncomeTemplateLinesTableProcessedTableManager get incomeTemplateLinesRefs {
    final manager = $$IncomeTemplateLinesTableTableManager(
      $_db,
      $_db.incomeTemplateLines,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomeTemplateLinesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IncomeTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeTemplatesTable> {
  $$IncomeTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> incomeTemplateLinesRefs(
    Expression<bool> Function($$IncomeTemplateLinesTableFilterComposer f) f,
  ) {
    final $$IncomeTemplateLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.incomeTemplateLines,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeTemplateLinesTableFilterComposer(
            $db: $db,
            $table: $db.incomeTemplateLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IncomeTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeTemplatesTable> {
  $$IncomeTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IncomeTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeTemplatesTable> {
  $$IncomeTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get concept =>
      $composableBuilder(column: $table.concept, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> incomeTemplateLinesRefs<T extends Object>(
    Expression<T> Function($$IncomeTemplateLinesTableAnnotationComposer a) f,
  ) {
    final $$IncomeTemplateLinesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.incomeTemplateLines,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$IncomeTemplateLinesTableAnnotationComposer(
                $db: $db,
                $table: $db.incomeTemplateLines,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$IncomeTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeTemplatesTable,
          TemplateRow,
          $$IncomeTemplatesTableFilterComposer,
          $$IncomeTemplatesTableOrderingComposer,
          $$IncomeTemplatesTableAnnotationComposer,
          $$IncomeTemplatesTableCreateCompanionBuilder,
          $$IncomeTemplatesTableUpdateCompanionBuilder,
          (TemplateRow, $$IncomeTemplatesTableReferences),
          TemplateRow,
          PrefetchHooks Function({bool incomeTemplateLinesRefs})
        > {
  $$IncomeTemplatesTableTableManager(
    _$AppDatabase db,
    $IncomeTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IncomeTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> concept = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeTemplatesCompanion(
                id: id,
                name: name,
                concept: concept,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> concept = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IncomeTemplatesCompanion.insert(
                id: id,
                name: name,
                concept: concept,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncomeTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({incomeTemplateLinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (incomeTemplateLinesRefs) db.incomeTemplateLines,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (incomeTemplateLinesRefs)
                    await $_getPrefetchedData<
                      TemplateRow,
                      $IncomeTemplatesTable,
                      TemplateLineRow
                    >(
                      currentTable: table,
                      referencedTable: $$IncomeTemplatesTableReferences
                          ._incomeTemplateLinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$IncomeTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).incomeTemplateLinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$IncomeTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeTemplatesTable,
      TemplateRow,
      $$IncomeTemplatesTableFilterComposer,
      $$IncomeTemplatesTableOrderingComposer,
      $$IncomeTemplatesTableAnnotationComposer,
      $$IncomeTemplatesTableCreateCompanionBuilder,
      $$IncomeTemplatesTableUpdateCompanionBuilder,
      (TemplateRow, $$IncomeTemplatesTableReferences),
      TemplateRow,
      PrefetchHooks Function({bool incomeTemplateLinesRefs})
    >;
typedef $$IncomeTemplateLinesTableCreateCompanionBuilder =
    IncomeTemplateLinesCompanion Function({
      Value<int> id,
      required String templateId,
      required int amountCents,
      required Currency currency,
      Value<int> position,
    });
typedef $$IncomeTemplateLinesTableUpdateCompanionBuilder =
    IncomeTemplateLinesCompanion Function({
      Value<int> id,
      Value<String> templateId,
      Value<int> amountCents,
      Value<Currency> currency,
      Value<int> position,
    });

final class $$IncomeTemplateLinesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $IncomeTemplateLinesTable,
          TemplateLineRow
        > {
  $$IncomeTemplateLinesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $IncomeTemplatesTable _templateIdTable(_$AppDatabase db) => db
      .incomeTemplates
      .createAlias('income_template_lines__template_id__income_templates__id');

  $$IncomeTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$IncomeTemplatesTableTableManager(
      $_db,
      $_db.incomeTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IncomeTemplateLinesTableFilterComposer
    extends Composer<_$AppDatabase, $IncomeTemplateLinesTable> {
  $$IncomeTemplateLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$IncomeTemplatesTableFilterComposer get templateId {
    final $$IncomeTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.incomeTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.incomeTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeTemplateLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $IncomeTemplateLinesTable> {
  $$IncomeTemplateLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$IncomeTemplatesTableOrderingComposer get templateId {
    final $$IncomeTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.incomeTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.incomeTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeTemplateLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IncomeTemplateLinesTable> {
  $$IncomeTemplateLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$IncomeTemplatesTableAnnotationComposer get templateId {
    final $$IncomeTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.incomeTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IncomeTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.incomeTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IncomeTemplateLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IncomeTemplateLinesTable,
          TemplateLineRow,
          $$IncomeTemplateLinesTableFilterComposer,
          $$IncomeTemplateLinesTableOrderingComposer,
          $$IncomeTemplateLinesTableAnnotationComposer,
          $$IncomeTemplateLinesTableCreateCompanionBuilder,
          $$IncomeTemplateLinesTableUpdateCompanionBuilder,
          (TemplateLineRow, $$IncomeTemplateLinesTableReferences),
          TemplateLineRow,
          PrefetchHooks Function({bool templateId})
        > {
  $$IncomeTemplateLinesTableTableManager(
    _$AppDatabase db,
    $IncomeTemplateLinesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IncomeTemplateLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IncomeTemplateLinesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$IncomeTemplateLinesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => IncomeTemplateLinesCompanion(
                id: id,
                templateId: templateId,
                amountCents: amountCents,
                currency: currency,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String templateId,
                required int amountCents,
                required Currency currency,
                Value<int> position = const Value.absent(),
              }) => IncomeTemplateLinesCompanion.insert(
                id: id,
                templateId: templateId,
                amountCents: amountCents,
                currency: currency,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IncomeTemplateLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (templateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateId,
                                referencedTable:
                                    $$IncomeTemplateLinesTableReferences
                                        ._templateIdTable(db),
                                referencedColumn:
                                    $$IncomeTemplateLinesTableReferences
                                        ._templateIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IncomeTemplateLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IncomeTemplateLinesTable,
      TemplateLineRow,
      $$IncomeTemplateLinesTableFilterComposer,
      $$IncomeTemplateLinesTableOrderingComposer,
      $$IncomeTemplateLinesTableAnnotationComposer,
      $$IncomeTemplateLinesTableCreateCompanionBuilder,
      $$IncomeTemplateLinesTableUpdateCompanionBuilder,
      (TemplateLineRow, $$IncomeTemplateLinesTableReferences),
      TemplateLineRow,
      PrefetchHooks Function({bool templateId})
    >;
typedef $$RatesTableCreateCompanionBuilder =
    RatesCompanion Function({
      required Currency currency,
      required int rateCents,
      required DateTime asOf,
      required DateTime savedAt,
      Value<bool> isManual,
      Value<int> rowid,
    });
typedef $$RatesTableUpdateCompanionBuilder =
    RatesCompanion Function({
      Value<Currency> currency,
      Value<int> rateCents,
      Value<DateTime> asOf,
      Value<DateTime> savedAt,
      Value<bool> isManual,
      Value<int> rowid,
    });

class $$RatesTableFilterComposer extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get rateCents => $composableBuilder(
    column: $table.rateCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rateCents => $composableBuilder(
    column: $table.rateCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get asOf => $composableBuilder(
    column: $table.asOf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RatesTable> {
  $$RatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get rateCents =>
      $composableBuilder(column: $table.rateCents, builder: (column) => column);

  GeneratedColumn<DateTime> get asOf =>
      $composableBuilder(column: $table.asOf, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);
}

class $$RatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RatesTable,
          RateRow,
          $$RatesTableFilterComposer,
          $$RatesTableOrderingComposer,
          $$RatesTableAnnotationComposer,
          $$RatesTableCreateCompanionBuilder,
          $$RatesTableUpdateCompanionBuilder,
          (RateRow, BaseReferences<_$AppDatabase, $RatesTable, RateRow>),
          RateRow,
          PrefetchHooks Function()
        > {
  $$RatesTableTableManager(_$AppDatabase db, $RatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Currency> currency = const Value.absent(),
                Value<int> rateCents = const Value.absent(),
                Value<DateTime> asOf = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion(
                currency: currency,
                rateCents: rateCents,
                asOf: asOf,
                savedAt: savedAt,
                isManual: isManual,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Currency currency,
                required int rateCents,
                required DateTime asOf,
                required DateTime savedAt,
                Value<bool> isManual = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RatesCompanion.insert(
                currency: currency,
                rateCents: rateCents,
                asOf: asOf,
                savedAt: savedAt,
                isManual: isManual,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RatesTable,
      RateRow,
      $$RatesTableFilterComposer,
      $$RatesTableOrderingComposer,
      $$RatesTableAnnotationComposer,
      $$RatesTableCreateCompanionBuilder,
      $$RatesTableUpdateCompanionBuilder,
      (RateRow, BaseReferences<_$AppDatabase, $RatesTable, RateRow>),
      RateRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$IncomesTableTableManager get incomes =>
      $$IncomesTableTableManager(_db, _db.incomes);
  $$IncomeLinesTableTableManager get incomeLines =>
      $$IncomeLinesTableTableManager(_db, _db.incomeLines);
  $$OfferingsTableTableManager get offerings =>
      $$OfferingsTableTableManager(_db, _db.offerings);
  $$IncomeTemplatesTableTableManager get incomeTemplates =>
      $$IncomeTemplatesTableTableManager(_db, _db.incomeTemplates);
  $$IncomeTemplateLinesTableTableManager get incomeTemplateLines =>
      $$IncomeTemplateLinesTableTableManager(_db, _db.incomeTemplateLines);
  $$RatesTableTableManager get rates =>
      $$RatesTableTableManager(_db, _db.rates);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
