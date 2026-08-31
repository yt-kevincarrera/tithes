/// Recorta la hora de una fecha.
///
/// Los ingresos y los pagos se comparan por día, nunca por instante: un ingreso
/// registrado a las 22:30 del día del pago cuenta para ese pago.
DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// True si [a] cae en el mismo día que [b] o antes.
bool isOnOrBefore(DateTime a, DateTime b) =>
    !dateOnly(a).isAfter(dateOnly(b));

/// True si [a] cae en un día anterior al de [b].
bool isStrictlyBefore(DateTime a, DateTime b) =>
    dateOnly(a).isBefore(dateOnly(b));
