import 'currency.dart';

/// Un pago de diezmo ya hecho.
///
/// Es un registro histórico e inmutable: guarda las tasas y el porcentaje que
/// se usaron ese día, así que un pago de agosto siempre se ve con las tasas de
/// agosto aunque el mercado se mueva después.
class Payment {
  const Payment({
    required this.id,
    required this.date,
    required this.ratesUsed,
    required this.grossCupCents,
    required this.computedCupCents,
    required this.actualCupCents,
    required this.titheBasisPoints,
    required this.note,
  });

  final String id;
  final DateTime date;

  /// Centavos de CUP por unidad de cada moneda, congelados en este pago.
  final Map<Currency, int> ratesUsed;

  /// Total de los ingresos que cubrió, en centavos de CUP.
  final int grossCupCents;

  /// El diezmo exacto que salió del cálculo.
  final int computedCupCents;

  /// Lo que realmente se entregó. Suele ser lo calculado redondeado hacia
  /// arriba, pero el usuario puede haberlo cambiado.
  final int actualCupCents;

  final int titheBasisPoints;
  final String? note;

  /// Diferencia entre lo entregado y lo calculado. Es informativa: no se
  /// arrastra a períodos siguientes, por decisión de diseño.
  int get differenceCupCents => actualCupCents - computedCupCents;

  Payment copyWith({
    String? id,
    DateTime? date,
    Map<Currency, int>? ratesUsed,
    int? grossCupCents,
    int? computedCupCents,
    int? actualCupCents,
    int? titheBasisPoints,
    String? note,
  }) => Payment(
    id: id ?? this.id,
    date: date ?? this.date,
    ratesUsed: ratesUsed ?? this.ratesUsed,
    grossCupCents: grossCupCents ?? this.grossCupCents,
    computedCupCents: computedCupCents ?? this.computedCupCents,
    actualCupCents: actualCupCents ?? this.actualCupCents,
    titheBasisPoints: titheBasisPoints ?? this.titheBasisPoints,
    note: note ?? this.note,
  );
}
