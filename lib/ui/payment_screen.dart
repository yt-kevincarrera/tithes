import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/currency.dart';
import '../domain/income.dart';
import '../domain/tithe_calculator.dart';
import 'format.dart';
import 'theme.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  DateTime _date = DateTime.now();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  /// Mientras sea false, el campo del monto sigue al cálculo. En cuanto el
  /// usuario lo toca deja de moverse solo: cambiar la fecha no debe borrarle lo
  /// que acaba de escribir.
  bool _amountEdited = false;
  bool _saving = false;

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

  Future<void> _confirm(
    TitheCalculation calculation,
    List<Income> covered,
  ) async {
    final actual = parseAmountToCents(_amount.text);
    if (actual == null || actual < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto no se entiende.')),
      );
      return;
    }

    setState(() => _saving = true);

    await ref
        .read(repositoryProvider)
        .registerPayment(
          date: _date,
          // CUP no lleva tasa: guardarla seria ruido en el historial.
          ratesUsed: {
            for (final subtotal in calculation.subtotals)
              if (subtotal.currency != Currency.cup)
                subtotal.currency: subtotal.rateCents,
          },
          grossCupCents: calculation.grossCupCents,
          computedCupCents: calculation.titheCupCents,
          actualCupCents: actual,
          titheBasisPoints: calculation.titheBasisPoints,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          incomeIds: covered.map((i) => i.id).toList(),
        );

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pago de ${formatCents(actual)} CUP registrado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = ref.watch(homeSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pagar diezmo')),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (data) {
          if (data.rates == null || data.missingRates.isNotEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Faltan tasas de cambio. Escríbelas antes de pagar.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final covered = TitheCalculator.incomesCoveredBy(
            incomes: data.pending,
            paymentDate: _date,
          );
          final calculation = TitheCalculator.calculate(
            incomes: covered,
            rates: data.rates!,
            titheBasisPoints: data.titheBasisPoints,
          );

          if (!_amountEdited) {
            final proposed = centsToInput(calculation.proposedCupCents);
            if (_amount.text != proposed) _amount.text = proposed;
          }

          final left = data.pending.length - covered.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              Card(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row(
                        label: 'Ingresos que se saldan',
                        value: '${covered.length}',
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Total de esos ingresos',
                        value:
                            '${formatCentsCompact(calculation.grossCupCents)} CUP',
                      ),
                      const Divider(height: 24),
                      for (final subtotal in calculation.subtotals)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _Row(
                            label: subtotal.currency == Currency.cup
                                ? formatMoneyCompact(
                                    subtotal.amountCents,
                                    subtotal.currency,
                                  )
                                : '${formatMoneyCompact(subtotal.amountCents, subtotal.currency)}'
                                      ' × ${formatRate(subtotal.rateCents)}',
                            value: formatCentsCompact(subtotal.cupCents),
                            muted: true,
                          ),
                        ),
                      const Divider(height: 24),
                      _Row(
                        label: 'Diezmo exacto',
                        value:
                            '${formatCents(calculation.titheCupCents)} CUP',
                        emphasis: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ActionChip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text('Pago del ${formatLongDate(_date)}'),
                onPressed: _pickDate,
              ),
              if (left > 0) ...[
                const SizedBox(height: 8),
                Text(
                  left == 1
                      ? 'Queda 1 ingreso con fecha posterior; no entra en este pago.'
                      : 'Quedan $left ingresos con fecha posterior; no entran en este pago.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Cuánto vas a entregar',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amount,
                onChanged: (_) => setState(() => _amountEdited = true),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: tabularFigures,
                ),
                decoration: const InputDecoration(suffixText: 'CUP'),
              ),
              const SizedBox(height: 8),
              Text(
                'Propuesto: ${formatCentsCompact(calculation.proposedCupCents)} CUP '
                '(el exacto redondeado hacia arriba).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _note,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving || covered.isEmpty
                    ? null
                    : () => _confirm(calculation, covered),
                child: Text(
                  covered.isEmpty
                      ? 'Nada que pagar en esta fecha'
                      : 'Confirmar pago',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Al confirmar se congelan las tasas de hoy en este pago y esos '
                '${covered.length} ingresos dejan de contar para siempre.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.muted = false,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool muted;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = (emphasis
            ? theme.textTheme.titleMedium
            : theme.textTheme.bodyMedium)
        ?.copyWith(
          color: muted ? theme.colorScheme.onSurfaceVariant : null,
          fontFeatures: tabularFigures,
          fontWeight: emphasis ? FontWeight.w700 : null,
        );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
