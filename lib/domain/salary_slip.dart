import 'currency.dart';
import 'income.dart';
import 'period_label.dart';

/// Lo que se ha podido sacar de un slip de nómina.
class SalarySlip {
  const SalarySlip({
    required this.periodStart,
    required this.periodEnd,
    required this.lines,
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;

  final List<IncomeLine> lines;

  bool get isEmpty => lines.isEmpty;

  /// Identifica el slip para no importarlo dos veces.
  ///
  /// Va por período y no por fecha de importación justamente para que
  /// reenviar el mismo slip días después se reconozca como el mismo.
  String? get sourceKey => periodEnd == null
      ? null
      : 'slip:${_iso(periodStart)}_${_iso(periodEnd)}';

  /// Concepto sugerido, con el período dentro: "Salario 1–15 ago".
  ///
  /// El período vive aquí, en el texto, y no en la fecha del ingreso: la fecha
  /// del ingreso es el día en que llega el slip, que es cuando el dinero
  /// aparece de verdad. Fecharlo al cierre de la quincena haría que cada slip
  /// que llega con unos días de retraso entrara marcado como atrasado si entre
  /// medias se pagó el diezmo.
  String conceptLabel() => periodStart == null || periodEnd == null
      ? 'Salario'
      : 'Salario ${rangeLabel(periodStart!, periodEnd!)}';
}

String _iso(DateTime? date) => date == null
    ? '?'
    : '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';


/// Lee los slips de nómina que llegan por Telegram.
///
/// Solo interesan dos líneas de todo el mensaje: **Final Pay (CUP)**, que es lo
/// que de verdad se cobra en CUP, y **Salario Tropipay USD**. El resto son
/// desgloses y deducciones que ya están descontados en el Final Pay, así que
/// sumarlos contaría el mismo dinero dos veces.
abstract final class SalarySlipParser {
  /// Etiquetas que sí son dinero cobrado, con su moneda.
  ///
  /// El orden importa: es el que tendrán las líneas del ingreso.
  static const _fields = <(String, Currency)>[
    ('Final Pay (CUP)', Currency.cup),
    ('Salario Tropipay USD', Currency.usd),
  ];

  /// True si el texto parece un slip. Sirve para no intentar parsear cualquier
  /// cosa que se comparta con la app.
  static bool looksLikeSlip(String text) =>
      text.contains('Salary Slip') ||
      _fields.any((f) => text.contains(f.$1));

  static SalarySlip parse(String text) {
    final lines = <IncomeLine>[];

    for (final (label, currency) in _fields) {
      final cents = _amountAfter(text, label);
      if (cents != null && cents > 0) {
        lines.add(IncomeLine(amountCents: cents, currency: currency));
      }
    }

    return SalarySlip(
      periodStart: _dateAfter(text, 'From'),
      periodEnd: _dateAfter(text, 'To'),
      lines: lines,
    );
  }

  /// Busca `Etiqueta: $ 25,606.50` y devuelve centésimas.
  static int? _amountAfter(String text, String label) {
    final match = RegExp(
      '${RegExp.escape(label)}\\s*:\\s*\\\$?\\s*([0-9.,]+)',
    ).firstMatch(text);
    return match == null ? null : _slipAmountToCents(match.group(1)!);
  }

  /// Busca `From: 01-08-2026`.
  static DateTime? _dateAfter(String text, String label) {
    final match = RegExp(
      '(?:^|\\n)\\s*${RegExp.escape(label)}\\s*:\\s*(\\d{1,2})-(\\d{1,2})-(\\d{4})',
    ).firstMatch(text);
    if (match == null) return null;

    return DateTime(
      int.parse(match.group(3)!),
      int.parse(match.group(2)!),
      int.parse(match.group(1)!),
    );
  }
}

/// Convierte los números del slip a centésimas.
///
/// El slip usa siempre coma para los miles y punto para los decimales, y a
/// veces escribe tres decimales (`30,479.167`). No se puede reutilizar el
/// parser de la entrada del usuario, que tiene que adivinar cuál de los dos
/// separadores es el decimal porque la gente escribe de las dos maneras. Aquí
/// el formato es fijo y conocido, así que adivinar solo introduciría errores.
int? _slipAmountToCents(String raw) {
  final text = raw.replaceAll(',', '').trim();
  if (text.isEmpty) return null;

  final parts = text.split('.');
  if (parts.length > 2) return null;

  final units = int.tryParse(parts.first);
  if (units == null) return null;
  if (parts.length == 1) return units * 100;

  final fraction = parts[1];
  if (fraction.isEmpty || int.tryParse(fraction) == null) return null;

  // Con tres o más decimales se redondea al centavo: no existe moneda con
  // milésimas y quedarse con los dos primeros dígitos perdería medio centavo.
  if (fraction.length > 2) {
    final scaled = int.parse(fraction.substring(0, 3));
    return units * 100 + (scaled + 5) ~/ 10;
  }

  return units * 100 + int.parse(fraction.padRight(2, '0'));
}
