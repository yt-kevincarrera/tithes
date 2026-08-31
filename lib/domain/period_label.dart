const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String monthAbbr(int month) => _months[month - 1];

/// Cómo se dice un rango de fechas: "1–15 ago", "16 ago – 2 sep".
String rangeLabel(DateTime start, DateTime end) {
  final sameMonth = start.month == end.month && start.year == end.year;
  return sameMonth
      ? '${start.day}–${end.day} ${monthAbbr(end.month)}'
      : '${start.day} ${monthAbbr(start.month)} – '
            '${end.day} ${monthAbbr(end.month)}';
}

/// La quincena que se está cobrando hoy.
///
/// No es la quincena en curso sino **la que acaba de cerrar**, porque el
/// salario siempre llega después del período que paga: el slip de la primera
/// quincena aparece sobre el día 20, y el de la segunda a principios del mes
/// siguiente. Así, registrando el salario cualquier día después de cobrarlo, el
/// concepto sale correcto sin tocar nada.
(DateTime, DateTime) fortnightBeingPaid(DateTime today) {
  if (today.day > 15) {
    // Estamos en la segunda mitad: se cobra la primera.
    return (
      DateTime(today.year, today.month, 1),
      DateTime(today.year, today.month, 15),
    );
  }

  // Primeros del mes: se cobra la segunda mitad del mes anterior.
  final previousMonthEnd = DateTime(today.year, today.month, 0);
  return (
    DateTime(previousMonthEnd.year, previousMonthEnd.month, 16),
    previousMonthEnd,
  );
}

/// "1–15 ago" para la quincena que se está cobrando hoy.
String fortnightLabel(DateTime today) {
  final (start, end) = fortnightBeingPaid(today);
  return rangeLabel(start, end);
}

/// Marcador que se puede escribir en el concepto de una plantilla.
const kFortnightPlaceholder = '{quincena}';

/// Sustituye `{quincena}` por la quincena que se está cobrando.
///
/// Existe para que registrar el salario a mano siga siendo un toque: escribir
/// "Salario 1–15 ago" cada quincena es exactamente la fricción que la app
/// intenta quitar.
String expandPlaceholders(String text, {DateTime? today}) => text.replaceAll(
  kFortnightPlaceholder,
  fortnightLabel(today ?? DateTime.now()),
);
