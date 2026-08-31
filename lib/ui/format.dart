import 'package:intl/intl.dart';

import '../domain/currency.dart';

/// Formato cubano: punto para los miles, coma para los decimales.
final _amount = NumberFormat('#,##0.00', 'es');
final _whole = NumberFormat('#,##0', 'es');
final _dayMonth = DateFormat('d MMM', 'es');
final _dayMonthYear = DateFormat('d MMM yyyy', 'es');
final _longDate = DateFormat("d 'de' MMMM 'de' yyyy", 'es');

/// Centésimas a texto: 487324 -> "4.873,24".
String formatCents(int cents) => _amount.format(cents / 100);

/// Igual, pero sin decimales cuando no hacen falta. Para el número grande de la
/// pantalla de inicio, donde los centavos son ruido.
String formatCentsCompact(int cents) =>
    cents % 100 == 0 ? _whole.format(cents ~/ 100) : formatCents(cents);

String formatMoney(int cents, Currency currency) =>
    '${formatCents(cents)} ${currency.code}';

String formatMoneyCompact(int cents, Currency currency) =>
    '${formatCentsCompact(cents)} ${currency.code}';

/// Una tasa: 44000 -> "440", 44250 -> "442,50".
String formatRate(int rateCents) => formatCentsCompact(rateCents);

String formatDate(DateTime date) => _dayMonth.format(date);

String formatDateWithYear(DateTime date) => _dayMonthYear.format(date);

String formatLongDate(DateTime date) => _longDate.format(date);

/// Fecha relativa para lo reciente, absoluta para lo viejo.
String formatRelativeDate(DateTime date, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final target = _dateOnly(date);
  final days = today.difference(target).inDays;

  if (days == 0) return 'hoy';
  if (days == 1) return 'ayer';
  if (days > 1 && days < 7) return 'hace $days días';
  return today.year == target.year
      ? formatDate(target)
      : formatDateWithYear(target);
}

/// Convierte lo que el usuario teclea en centésimas.
///
/// Acepta coma o punto como separador decimal, y aguanta separadores de miles,
/// porque nadie va a acordarse de cuál toca al escribir deprisa.
int? parseAmountToCents(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;

  text = text.replaceAll(RegExp(r'\s'), '');

  final lastComma = text.lastIndexOf(',');
  final lastDot = text.lastIndexOf('.');
  final decimalMark = lastComma > lastDot ? ',' : (lastDot > -1 ? '.' : null);

  if (decimalMark != null) {
    final index = text.lastIndexOf(decimalMark);
    final integerPart = text.substring(0, index).replaceAll(RegExp(r'[.,]'), '');
    final fractionPart = text.substring(index + 1);

    // Más de dos decimales significa que no era un separador decimal sino de
    // miles: "1.234" son mil doscientos treinta y cuatro, no 1,234.
    if (fractionPart.length > 2 || fractionPart.isEmpty) {
      return _digitsToCents(text.replaceAll(RegExp(r'[.,]'), ''));
    }

    final cents = int.tryParse(fractionPart.padRight(2, '0'));
    final units = integerPart.isEmpty ? 0 : int.tryParse(integerPart);
    if (cents == null || units == null) return null;
    return units * 100 + cents;
  }

  return _digitsToCents(text);
}

int? _digitsToCents(String digits) {
  final units = int.tryParse(digits);
  return units == null ? null : units * 100;
}

/// Texto editable a partir de centésimas, para rellenar un campo.
String centsToInput(int cents) =>
    cents % 100 == 0 ? '${cents ~/ 100}' : (cents / 100).toStringAsFixed(2);

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
