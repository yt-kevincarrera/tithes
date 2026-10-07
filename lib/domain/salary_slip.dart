import 'currency.dart';
import 'income.dart';
import 'period_label.dart';

/// Una deducción del slip que no está en el Final Pay y se resta del USD.
class SlipDeduction {
  const SlipDeduction({required this.label, required this.amountCents});

  final String label;
  final int amountCents;
}

/// Lo que se ha podido sacar de un slip de nómina.
class SalarySlip {
  const SalarySlip({
    required this.periodStart,
    required this.periodEnd,
    required this.lines,
    this.deductions = const [],
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;

  final List<IncomeLine> lines;

  /// Deducciones ya restadas del USD en [lines]; sirven para avisar al usuario.
  final List<SlipDeduction> deductions;

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
/// De todo el mensaje solo son dinero cobrado tres líneas: **Final Pay (CUP)**,
/// **Salario Tropipay USD** y **Bono**, cuando aparece.
///
/// El resto —`Salario Quincenal CUP`, `Base Impositiva`, las deducciones— son
/// el desglose del que sale el Final Pay, y sumarlos contaría el mismo dinero
/// dos veces. La aritmética de los slips reales lo confirma:
///
/// ```
/// 33.250,00 − 4.693,50 − 2.950,00 = 25.606,50 = Final Pay
/// 33.750,00 − 4.793,50 − 3.000,00 = 25.956,50 = Final Pay
/// ```
///
/// Y confirma también lo contrario: el Final Pay **no** incluye ni los USD de
/// Tropipay ni el Bono, así que esos sí hay que sumarlos aparte.
abstract final class SalarySlipParser {
  /// Etiquetas que sí son dinero cobrado, con su moneda.
  ///
  /// El orden importa: es el que tendrán las líneas del ingreso.
  static const _fields = <(String, Currency)>[
    ('Final Pay (CUP)', Currency.cup),
    ('Salario Tropipay USD', Currency.usd),
    // El slip no dice la moneda del bono, a diferencia de los campos en CUP,
    // que la llevan en la etiqueta. Confirmado con el usuario: es USD.
    ('Bono', Currency.usd),
  ];

  /// True si el texto parece un slip. Sirve para no intentar parsear cualquier
  /// cosa que se comparta con la app.
  static bool looksLikeSlip(String text) =>
      text.contains('Salary Slip') ||
      _fields.any((f) => text.contains(f.$1));

  /// Deducciones que el Final Pay ya tiene descontadas. Restarlas otra vez
  /// sería descontarlas dos veces.
  static const _alreadyInFinalPay = ['Ingresos Personales', 'Seguridad Social'];

  static SalarySlip parse(String text) {
    final lines = <IncomeLine>[];

    for (final (label, currency) in _fields) {
      final cents = _amountAfter(text, label);
      if (cents != null && cents > 0) {
        lines.add(IncomeLine(amountCents: cents, currency: currency));
      }
    }

    final deductions = _extraDeductions(text);
    final deducted = deductions.fold<int>(0, (sum, d) => sum + d.amountCents);
    final adjusted = deducted == 0 ? lines : _applyUsdDeductions(lines, deducted);

    return SalarySlip(
      periodStart: _dateAfter(text, 'From'),
      periodEnd: _dateAfter(text, 'To'),
      lines: adjusted,
      deductions: deductions,
    );
  }

  /// Junta el USD del slip (Tropipay + bono) en una sola línea y le resta las
  /// deducciones. Si no queda nada, no deja línea en USD.
  static List<IncomeLine> _applyUsdDeductions(
    List<IncomeLine> lines,
    int deducted,
  ) {
    final usd = lines
        .where((l) => l.currency == Currency.usd)
        .fold<int>(0, (sum, l) => sum + l.amountCents);
    final net = usd - deducted;

    return [
      ...lines.where((l) => l.currency != Currency.usd),
      if (net > 0) IncomeLine(amountCents: net, currency: Currency.usd),
    ];
  }

  /// Las deducciones de la sección `Deductions` que el Final Pay no incluye,
  /// p. ej. `Deducción - Loan Crédito Trabajadores: $ 250`. Se dan en USD.
  static List<SlipDeduction> _extraDeductions(String text) {
    final start = RegExp(r'^\s*Deductions\s*$', multiLine: true)
        .firstMatch(text);
    if (start == null) return const [];

    var section = text.substring(start.end);
    final end = RegExp(r'^\s*Final Pay', multiLine: true).firstMatch(section);
    if (end != null) section = section.substring(0, end.start);

    final result = <SlipDeduction>[];
    final row = RegExp(r'^\s*(.+?)\s*:\s*\$?\s*([0-9.,]+)\s*$');
    for (final line in section.split('\n')) {
      final match = row.firstMatch(line);
      if (match == null) continue;

      final label = match.group(1)!;
      if (_alreadyInFinalPay.any(label.startsWith)) continue;

      final cents = _slipAmountToCents(match.group(2)!);
      if (cents != null && cents > 0) {
        result.add(SlipDeduction(label: label, amountCents: cents));
      }
    }
    return result;
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
