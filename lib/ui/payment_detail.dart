import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/income.dart';
import '../domain/payment.dart';
import 'format.dart';
import 'theme.dart';
import 'widgets/sheet_scaffold.dart';

Future<void> showPaymentDetail(BuildContext context, Payment payment) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PaymentDetail(payment: payment),
    );

/// Un pago, tal como quedó registrado.
///
/// Enseña las tasas congeladas de ese día, no las de hoy: es lo que hace que el
/// historial se pueda auditar meses después.
class PaymentDetail extends ConsumerWidget {
  const PaymentDetail({super.key, required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final incomes = ref
        .watch(incomesOfPaymentProvider(payment.id))
        .valueOrNull;

    return SheetScaffold(
      title: 'Pago del ${formatDateWithYear(payment.date)}',
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entregado',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                Text(
                  '${formatCentsCompact(payment.actualCupCents)} CUP',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                ),
                if (payment.differenceCupCents != 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    payment.differenceCupCents > 0
                        ? '${formatCents(payment.differenceCupCents)} CUP más que el cálculo exacto'
                        : '${formatCents(-payment.differenceCupCents)} CUP menos que el cálculo exacto',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _Line(
          label: 'Diezmo exacto',
          value: '${formatCents(payment.computedCupCents)} CUP',
        ),
        _Line(
          label: 'Ingresos cubiertos',
          value: '${formatCentsCompact(payment.grossCupCents)} CUP',
        ),
        _Line(
          label: 'Porcentaje',
          value: '${payment.titheBasisPoints / 100} %',
        ),
        if (payment.note != null) _Line(label: 'Nota', value: payment.note!),
        if (payment.ratesUsed.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Tasas usadas ese día',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (final entry in payment.ratesUsed.entries)
            _Line(
              label: entry.key.code,
              value: '${formatRate(entry.value)} CUP',
            ),
        ],
        const SizedBox(height: 20),
        Text(
          'Ingresos saldados',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        if (incomes == null)
          const Padding(
            padding: EdgeInsets.all(12),
            child: LinearProgressIndicator(),
          )
        else if (incomes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Ninguno.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          for (final income in incomes) _IncomeRow(income: income),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _undo(context, ref),
          icon: const Icon(Icons.undo),
          label: const Text('Deshacer este pago'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Los ingresos volverían a estar pendientes y se recalcularían con las '
          'tasas de hoy.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _undo(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Deshacer el pago?'),
        content: const Text(
          'Los ingresos que cubría volverán a contar como pendientes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deshacer'),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false)) return;
    await ref.read(repositoryProvider).undoPayment(payment.id);
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeRow extends StatelessWidget {
  const _IncomeRow({required this.income});

  final Income income;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.concept.isEmpty ? 'Ingreso' : income.concept,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  formatDateWithYear(income.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final line in income.lines)
                Text(
                  formatMoneyCompact(line.amountCents, line.currency),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFeatures: tabularFigures,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
