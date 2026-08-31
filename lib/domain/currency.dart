/// Monedas que la app sabe manejar.
///
/// [Currency.cup] es la moneda de referencia: todo se convierte a ella y el
/// diezmo se paga en ella.
enum Currency {
  cup(code: 'CUP', label: 'CUP', symbol: r'$'),
  usd(code: 'USD', label: 'USD', symbol: r'$'),
  eur(code: 'EUR', label: 'EUR', symbol: '€'),
  mlc(code: 'MLC', label: 'MLC', symbol: r'$');

  const Currency({required this.code, required this.label, required this.symbol});

  final String code;
  final String label;
  final String symbol;

  /// Las monedas que necesitan tasa de cambio para valorarse en CUP.
  static const foreign = [Currency.usd, Currency.eur, Currency.mlc];

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code.toUpperCase(),
    orElse: () => throw ArgumentError('Moneda desconocida: $code'),
  );
}
