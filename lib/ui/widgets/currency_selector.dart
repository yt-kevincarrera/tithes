import 'package:flutter/material.dart';

import '../../domain/currency.dart';

/// Selector de moneda de un solo toque.
///
/// Con cuatro monedas caben todas en pantalla, así que un desplegable solo
/// añadiría un toque de más a la acción que se repite en cada línea de cada
/// ingreso.
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final Currency value;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Currency>(
      segments: [
        for (final currency in Currency.values)
          ButtonSegment(value: currency, label: Text(currency.label)),
      ],
      selected: {value},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
