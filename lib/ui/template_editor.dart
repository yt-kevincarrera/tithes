import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/currency.dart';
import '../domain/income.dart';
import '../domain/income_template.dart';
import 'format.dart';
import 'widgets/currency_selector.dart';
import 'widgets/sheet_scaffold.dart';

Future<void> showTemplateEditor(
  BuildContext context, {
  IncomeTemplate? template,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => TemplateEditor(template: template),
);

/// Editor de plantillas.
///
/// Una plantilla es el molde de un ingreso que se repite —el salario— con sus
/// monedas ya puestas, para que registrarlo sea confirmar en vez de teclear.
class TemplateEditor extends ConsumerStatefulWidget {
  const TemplateEditor({super.key, this.template});

  final IncomeTemplate? template;

  @override
  ConsumerState<TemplateEditor> createState() => _TemplateEditorState();
}

class _Draft {
  _Draft({required this.currency, String amount = ''})
    : controller = TextEditingController(text: amount);

  Currency currency;
  final TextEditingController controller;
}

class _TemplateEditorState extends ConsumerState<TemplateEditor> {
  late final TextEditingController _name;
  late final TextEditingController _concept;
  late List<_Draft> _lines;
  String? _error;

  @override
  void initState() {
    super.initState();
    final source = widget.template;
    _name = TextEditingController(text: source?.name ?? '');
    _concept = TextEditingController(text: source?.concept ?? '');
    _lines = source == null || source.lines.isEmpty
        ? [_Draft(currency: Currency.cup)]
        : [
            for (final line in source.lines)
              _Draft(
                currency: line.currency,
                amount: centsToInput(line.amountCents),
              ),
          ];
  }

  @override
  void dispose() {
    _name.dispose();
    _concept.dispose();
    for (final line in _lines) {
      line.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Ponle un nombre a la plantilla.');
      return;
    }

    final lines = <IncomeLine>[];
    for (final line in _lines) {
      final text = line.controller.text.trim();
      if (text.isEmpty) continue;
      final cents = parseAmountToCents(text);
      if (cents == null || cents <= 0) {
        setState(() => _error = 'Hay un monto que no se entiende: "$text".');
        return;
      }
      lines.add(IncomeLine(amountCents: cents, currency: line.currency));
    }

    if (lines.isEmpty) {
      setState(() => _error = 'Escribe al menos un monto.');
      return;
    }

    await ref
        .read(repositoryProvider)
        .saveTemplate(
          id: widget.template?.id,
          name: name,
          concept: _concept.text.trim(),
          lines: lines,
          sortOrder: widget.template?.sortOrder ?? 0,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      title: widget.template == null ? 'Nueva plantilla' : 'Editar plantilla',
      children: [
        TextField(
          controller: _name,
          autofocus: widget.template == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Salario',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _concept,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Concepto que se rellenará',
            hintText: 'salario',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Montos por defecto',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _lines.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lines[i].controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        style: theme.textTheme.titleLarge,
                        decoration: const InputDecoration(
                          hintText: '0',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_lines.length > 1)
                      IconButton(
                        onPressed: () => setState(() => _lines.removeAt(i)),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                CurrencySelector(
                  value: _lines[i].currency,
                  onChanged: (currency) =>
                      setState(() => _lines[i].currency = currency),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final used = _lines.map((l) => l.currency).toSet();
              final next = Currency.values.firstWhere(
                (c) => !used.contains(c),
                orElse: () => Currency.cup,
              );
              setState(() => _lines.add(_Draft(currency: next)));
            },
            icon: const Icon(Icons.add),
            label: const Text('Añadir otra moneda'),
          ),
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
        FilledButton(onPressed: _save, child: const Text('Guardar plantilla')),
      ],
    );
  }
}
