import 'income.dart';

/// Una plantilla de ingreso recurrente.
///
/// Existe para matar la fricción del caso más común: el salario quincenal, que
/// siempre trae los mismos montos en las mismas monedas. Un toque en la
/// plantilla abre el formulario relleno con la fecha de hoy y solo hay que
/// confirmar.
class IncomeTemplate {
  const IncomeTemplate({
    required this.id,
    required this.name,
    required this.concept,
    required this.lines,
    required this.sortOrder,
  });

  final String id;

  /// Lo que se lee en el botón de la pantalla de inicio, p. ej. "Salario".
  final String name;

  final String concept;
  final List<IncomeLine> lines;
  final int sortOrder;

  IncomeTemplate copyWith({
    String? id,
    String? name,
    String? concept,
    List<IncomeLine>? lines,
    int? sortOrder,
  }) => IncomeTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    concept: concept ?? this.concept,
    lines: lines ?? this.lines,
    sortOrder: sortOrder ?? this.sortOrder,
  );
}
