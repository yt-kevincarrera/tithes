import 'currency.dart';

/// Una parte de un ingreso en una moneda concreta.
///
/// Existe porque un mismo cobro puede llegar partido: 200 USD en efectivo más
/// 5 000 CUP en la tarjeta son un solo ingreso, no dos.
class IncomeLine {
  const IncomeLine({required this.amountCents, required this.currency});

  /// Centésimas de la unidad monetaria. 20000 = 200,00.
  final int amountCents;
  final Currency currency;

  IncomeLine copyWith({int? amountCents, Currency? currency}) => IncomeLine(
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
  );

  @override
  bool operator ==(Object other) =>
      other is IncomeLine &&
      other.amountCents == amountCents &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(amountCents, currency);

  @override
  String toString() => 'IncomeLine($amountCents ${currency.code})';
}

/// Un ingreso recibido. Está pendiente de diezmar mientras [paymentId] sea
/// null; una vez saldado guarda el pago que lo cubrió y ya nunca vuelve a
/// contar.
class Income {
  const Income({
    required this.id,
    required this.date,
    required this.concept,
    required this.note,
    required this.paymentId,
    required this.lines,
  });

  final String id;
  final DateTime date;
  final String concept;
  final String? note;
  final String? paymentId;
  final List<IncomeLine> lines;

  bool get isPending => paymentId == null;

  Income copyWith({
    String? id,
    DateTime? date,
    String? concept,
    String? note,
    String? paymentId,
    bool clearPaymentId = false,
    List<IncomeLine>? lines,
  }) => Income(
    id: id ?? this.id,
    date: date ?? this.date,
    concept: concept ?? this.concept,
    note: note ?? this.note,
    paymentId: clearPaymentId ? null : (paymentId ?? this.paymentId),
    lines: lines ?? this.lines,
  );

  @override
  String toString() => 'Income($id, $date, ${lines.length} líneas)';
}
