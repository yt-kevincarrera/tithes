import 'currency.dart';

/// Una ofrenda entregada.
///
/// No se calcula ni se debe: es voluntaria y se registra cuando se da. Vive
/// aparte del diezmo a propósito, y no entra en ningún cálculo de deuda.
class Offering {
  const Offering({
    required this.id,
    required this.date,
    required this.amountCents,
    required this.currency,
    required this.note,
  });

  final String id;
  final DateTime date;
  final int amountCents;
  final Currency currency;
  final String? note;

  Offering copyWith({
    String? id,
    DateTime? date,
    int? amountCents,
    Currency? currency,
    String? note,
  }) => Offering(
    id: id ?? this.id,
    date: date ?? this.date,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    note: note ?? this.note,
  );
}
