import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/currency.dart';
import '../domain/income.dart';
import '../domain/income_template.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets/currency_selector.dart';
import 'widgets/sheet_scaffold.dart';

/// Abre el editor de ingresos.
///
/// Sirve para los tres caminos: ingreso nuevo en blanco, ingreso nuevo desde
/// una plantilla ya rellena, y edición de uno existente.
Future<void> showIncomeEditor(
  BuildContext context, {
  Income? income,
  IncomeTemplate? template,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => IncomeEditor(income: income, template: template),
);

class IncomeEditor extends ConsumerStatefulWidget {
  const IncomeEditor({super.key, this.income, this.template});

  final Income? income;
  final IncomeTemplate? template;

  @override
  ConsumerState<IncomeEditor> createState() => _IncomeEditorState();
}

class _LineDraft {
  _LineDraft({required this.currency, String amount = ''})
    : controller = TextEditingController(text: amount);

  Currency currency;
  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class _IncomeEditorState extends ConsumerState<IncomeEditor> {
  late DateTime _date;
  late final TextEditingController _concept;
  late final TextEditingController _note;
  late List<_LineDraft> _lines;
  bool _showNote = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final source = widget.income;
    final template = widget.template;

    _date = source?.date ?? DateTime.now();
    _concept = TextEditingController(
      text: source?.concept ?? template?.concept ?? '',
    );
    _note = TextEditingController(text: source?.note ?? '');
    _showNote = (source?.note ?? '').isNotEmpty;

    final lines = source?.lines ?? template?.lines;
    _lines = lines == null || lines.isEmpty
        ? [_LineDraft(currency: Currency.cup)]
        : [
            for (final line in lines)
              _LineDraft(
                currency: line.currency,
                amount: centsToInput(line.amountCents),
              ),
          ];
  }

  @override
  void dispose() {
    _concept.dispose();
    _note.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  bool get _isEditing => widget.income != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addLine() {
    // Se propone una moneda que todavía no esté puesta: quien añade una
    // segunda línea casi nunca quiere repetir la misma.
    final used = _lines.map((l) => l.currency).toSet();
    final next = Currency.values.firstWhere(
      (c) => !used.contains(c),
      orElse: () => Currency.cup,
    );
    setState(() => _lines.add(_LineDraft(currency: next)));
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index).dispose();
      if (_lines.isEmpty) _lines.add(_LineDraft(currency: Currency.cup));
    });
  }

  List<IncomeLine>? _collectLines() {
    final result = <IncomeLine>[];

    for (final line in _lines) {
      final text = line.controller.text.trim();
      if (text.isEmpty) continue;

      final cents = parseAmountToCents(text);
      if (cents == null) {
        setState(() => _error = 'Hay un monto que no se entiende: "$text".');
        return null;
      }
      if (cents <= 0) {
        setState(() => _error = 'Los montos tienen que ser mayores que cero.');
        return null;
      }
      result.add(IncomeLine(amountCents: cents, currency: line.currency));
    }

    if (result.isEmpty) {
      setState(() => _error = 'Escribe al menos un monto.');
      return null;
    }
    return result;
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final lines = _collectLines();
    if (lines == null) return;

    setState(() => _saving = true);
    await ref
        .read(repositoryProvider)
        .saveIncome(
          id: widget.income?.id,
          date: _date,
          concept: _concept.text.trim(),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          lines: lines,
        );

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveAsTemplate() async {
    setState(() => _error = null);
    final lines = _collectLines();
    if (lines == null) return;

    final name = await _askTemplateName();
    if (name == null || !mounted) return;

    await ref
        .read(repositoryProvider)
        .saveTemplate(
          name: name,
          concept: _concept.text.trim(),
          lines: lines,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plantilla "$name" guardada')),
    );
  }

  Future<String?> _askTemplateName() {
    final controller = TextEditingController(
      text: _concept.text.trim().isEmpty ? 'Salario' : _concept.text.trim(),
    );

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre de la plantilla'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Salario'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.pop(context, value.isEmpty ? null : value);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      title: _isEditing ? 'Editar ingreso' : 'Nuevo ingreso',
      actions: [
        IconButton(
          onPressed: _saving ? null : _saveAsTemplate,
          icon: const Icon(Icons.bookmark_add_outlined),
          tooltip: 'Guardar como plantilla',
        ),
      ],
      children: [
        Row(
          children: [
            Expanded(
              child: ActionChip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text(formatLongDate(_date)),
                onPressed: _pickDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _concept,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Concepto',
            hintText: 'salario, freelance, regalo…',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Montos',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _lines.length; i++) ...[
          _LineEditor(
            key: ObjectKey(_lines[i]),
            draft: _lines[i],
            autofocus: i == 0 && !_isEditing && widget.template == null,
            canRemove: _lines.length > 1,
            onRemove: () => _removeLine(i),
            onCurrencyChanged: (currency) =>
                setState(() => _lines[i].currency = currency),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addLine,
            icon: const Icon(Icons.add),
            label: const Text('Añadir otra moneda'),
          ),
        ),
        const SizedBox(height: 8),
        if (_showNote)
          TextField(
            controller: _note,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nota'),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _showNote = true),
              icon: const Icon(Icons.notes),
              label: const Text('Añadir nota'),
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
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_isEditing ? 'Guardar cambios' : 'Registrar ingreso'),
        ),
      ],
    );
  }
}

class _LineEditor extends StatelessWidget {
  const _LineEditor({
    super.key,
    required this.draft,
    required this.autofocus,
    required this.canRemove,
    required this.onRemove,
    required this.onCurrencyChanged,
  });

  final _LineDraft draft;
  final bool autofocus;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<Currency> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.controller,
                  autofocus: autofocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFeatures: tabularFigures,
                    fontWeight: FontWeight.w600,
                  ),
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
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  tooltip: 'Quitar esta moneda',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 8),
          CurrencySelector(
            value: draft.currency,
            onChanged: onCurrencyChanged,
          ),
        ],
      ),
    );
  }
}
