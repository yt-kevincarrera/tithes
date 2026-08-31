import 'income.dart';

/// Un ingreso a medio hacer, todavía sin guardar.
///
/// Unifica las tres formas de llegar al formulario —en blanco, desde una
/// plantilla y desde un slip compartido— para que el editor no tenga que saber
/// de dónde vino lo que muestra.
class IncomeDraft {
  const IncomeDraft({
    this.date,
    this.concept = '',
    this.note,
    this.lines = const [],
    this.sourceKey,
  });

  final DateTime? date;
  final String concept;
  final String? note;
  final List<IncomeLine> lines;

  /// De dónde salió, cuando no lo tecleó el usuario. Ver `Incomes.sourceKey`.
  final String? sourceKey;
}
