import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/currency.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets/sheet_scaffold.dart';

Future<void> showRateEditor(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const RateEditor(),
    );

/// Ver y sobrescribir las tasas.
///
/// La edición a mano es la red de seguridad de toda la app: mientras exista,
/// ningún problema de red, de token o de sanciones deja la app inservible.
class RateEditor extends ConsumerStatefulWidget {
  const RateEditor({super.key});

  @override
  ConsumerState<RateEditor> createState() => _RateEditorState();
}

class _RateEditorState extends ConsumerState<RateEditor> {
  final _controllers = <Currency, TextEditingController>{};
  Set<Currency> _manual = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    for (final currency in Currency.foreign) {
      _controllers[currency] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(repositoryProvider);
    final rates = await repo.currentRates();
    final manual = await repo.manualCurrencies();
    if (!mounted) return;

    setState(() {
      _manual = manual;
      for (final currency in Currency.foreign) {
        final value = rates?.values[currency];
        _controllers[currency]!.text = value == null ? '' : centsToInput(value);
      }
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveManual(Currency currency) async {
    final cents = parseAmountToCents(_controllers[currency]!.text);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La tasa de ${currency.code} no se entiende.')),
      );
      return;
    }

    await ref
        .read(repositoryProvider)
        .saveManualRate(currency: currency, rateCents: cents);
    if (!mounted) return;
    setState(() => _manual = {..._manual, currency});
  }

  Future<void> _clearManual(Currency currency) async {
    await ref.read(repositoryProvider).clearManualRate(currency);
    if (!mounted) return;
    setState(() => _manual = {..._manual}..remove(currency));
    await _load();
  }

  Future<void> _refresh() async {
    await ref.read(ratesRefresherProvider.notifier).refresh();
    if (!mounted) return;

    final error = ref.read(ratesRefresherProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final refreshing = ref.watch(ratesRefresherProvider).isRefreshing;

    return SheetScaffold(
      title: 'Tasas de cambio',
      actions: [
        IconButton(
          onPressed: refreshing ? null : _refresh,
          icon: refreshing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          tooltip: 'Bajar de elToque',
        ),
      ],
      children: [
        Text(
          'Cuántos CUP vale una unidad de cada moneda. Lo que escribas a mano '
          'manda sobre lo que baje de elToque.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        if (!_loaded)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else
          for (final currency in Currency.foreign) ...[
            _RateField(
              currency: currency,
              controller: _controllers[currency]!,
              isManual: _manual.contains(currency),
              onSave: () => _saveManual(currency),
              onClear: () => _clearManual(currency),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 8),
        Text(
          'Tasas del mercado informal de elTOQUE (eltoque.com). Son valores '
          'referenciales.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _RateField extends StatelessWidget {
  const _RateField({
    required this.currency,
    required this.controller,
    required this.isManual,
    required this.onSave,
    required this.onClear,
  });

  final Currency currency;
  final TextEditingController controller;
  final bool isManual;
  final VoidCallback onSave;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currency.code, style: theme.textTheme.titleMedium),
              if (isManual)
                Text(
                  'a mano',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: theme.textTheme.titleMedium?.copyWith(
              fontFeatures: tabularFigures,
            ),
            decoration: const InputDecoration(
              suffixText: 'CUP',
              isDense: true,
            ),
            onSubmitted: (_) => onSave(),
          ),
        ),
        const SizedBox(width: 8),
        if (isManual)
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.undo),
            tooltip: 'Volver a la de elToque',
          )
        else
          IconButton(
            onPressed: onSave,
            icon: const Icon(Icons.check),
            tooltip: 'Fijar a mano',
          ),
      ],
    );
  }
}
