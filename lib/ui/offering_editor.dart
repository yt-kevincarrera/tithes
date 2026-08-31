import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/currency.dart';
import '../domain/offering.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets/currency_selector.dart';
import 'widgets/sheet_scaffold.dart';

Future<void> showOfferingEditor(BuildContext context, {Offering? offering}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => OfferingEditor(offering: offering),
    );

/// Registrar una ofrenda.
///
/// Es un formulario aparte y mucho más corto que el de ingresos porque una
/// ofrenda no se calcula ni se debe: es un solo monto, ya entregado.
class OfferingEditor extends ConsumerStatefulWidget {
  const OfferingEditor({super.key, this.offering});

  final Offering? offering;

  @override
  ConsumerState<OfferingEditor> createState() => _OfferingEditorState();
}

class _OfferingEditorState extends ConsumerState<OfferingEditor> {
  late DateTime _date;
  late Currency _currency;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    final source = widget.offering;
    _date = source?.date ?? DateTime.now();
    _currency = source?.currency ?? Currency.cup;
    _amount = TextEditingController(
      text: source == null ? '' : centsToInput(source.amountCents),
    );
    _note = TextEditingController(text: source?.note ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final cents = parseAmountToCents(_amount.text);
    if (cents == null || cents <= 0) {
      setState(() => _error = 'Escribe un monto mayor que cero.');
      return;
    }

    await ref
        .read(repositoryProvider)
        .saveOffering(
          id: widget.offering?.id,
          date: _date,
          amountCents: cents,
          currency: _currency,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      title: widget.offering == null ? 'Nueva ofrenda' : 'Editar ofrenda',
      children: [
        ActionChip(
          avatar: const Icon(Icons.event, size: 18),
          label: Text(formatLongDate(_date)),
          onPressed: _pickDate,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amount,
          autofocus: widget.offering == null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: tabularFigures,
          ),
          decoration: const InputDecoration(hintText: '0'),
        ),
        const SizedBox(height: 12),
        CurrencySelector(
          value: _currency,
          onChanged: (currency) => setState(() => _currency = currency),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nota (opcional)'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(onPressed: _save, child: const Text('Guardar ofrenda')),
        const SizedBox(height: 12),
        Text(
          'Las ofrendas no entran en el cálculo del diezmo. Se guardan solo '
          'para que quede constancia.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
