import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/date_only.dart';
import '../domain/offering.dart';
import '../domain/payment.dart';
import 'format.dart';
import 'offering_editor.dart';
import 'payment_detail.dart';
import 'theme.dart';

/// Los rangos que se pueden mirar.
///
/// No son períodos de verdad —el período real es "desde el último pago"— sino
/// una lente para leer el historial.
enum HistoryRange {
  thisMonth('Este mes'),
  lastMonth('Mes pasado'),
  thisYear('Este año'),
  all('Todo');

  const HistoryRange(this.label);

  final String label;

  (DateTime, DateTime)? boundsAt(DateTime now) {
    final today = dateOnly(now);
    return switch (this) {
      HistoryRange.thisMonth => (
        DateTime(today.year, today.month),
        DateTime(today.year, today.month + 1, 0),
      ),
      HistoryRange.lastMonth => (
        DateTime(today.year, today.month - 1),
        DateTime(today.year, today.month, 0),
      ),
      HistoryRange.thisYear => (
        DateTime(today.year),
        DateTime(today.year, 12, 31),
      ),
      HistoryRange.all => null,
    };
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryRange _range = HistoryRange.thisMonth;

  bool _inRange(DateTime date) {
    final bounds = _range.boundsAt(DateTime.now());
    if (bounds == null) return true;
    final (from, to) = bounds;
    return !dateOnly(date).isBefore(from) && !dateOnly(date).isAfter(to);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payments = ref.watch(paymentsProvider).valueOrNull ?? const [];
    final offerings = ref.watch(offeringsProvider).valueOrNull ?? const [];

    final visiblePayments = payments.where((p) => _inRange(p.date)).toList();
    final visibleOfferings = offerings.where((o) => _inRange(o.date)).toList();

    final entries = <_Entry>[
      ...visiblePayments.map(_Entry.payment),
      ...visibleOfferings.map(_Entry.offering),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final tithePaid = visiblePayments.fold<int>(
      0,
      (sum, p) => sum + p.actualCupCents,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final range in HistoryRange.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(range.label),
                      selected: _range == range,
                      onSelected: (_) => setState(() => _range = range),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: _Total(
                    label: 'Diezmo pagado',
                    value: '${formatCentsCompact(tithePaid)} CUP',
                  ),
                ),
                Expanded(
                  child: _Total(
                    label: 'Ofrendas',
                    value: '${visibleOfferings.length}',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Nada en este rango.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        entries[index].build(context, ref),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showOfferingEditor(context),
        icon: const Icon(Icons.favorite_outline),
        label: const Text('Ofrenda'),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: tabularFigures,
          ),
        ),
      ],
    );
  }
}

/// Un pago o una ofrenda, para poder ordenarlos juntos en la misma línea de
/// tiempo.
class _Entry {
  _Entry.payment(Payment payment)
    : paymentValue = payment,
      offeringValue = null,
      date = payment.date;

  _Entry.offering(Offering offering)
    : paymentValue = null,
      offeringValue = offering,
      date = offering.date;

  final Payment? paymentValue;
  final Offering? offeringValue;
  final DateTime date;

  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final payment = paymentValue;

    if (payment != null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.volunteer_activism_outlined,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          '${formatCentsCompact(payment.actualCupCents)} CUP',
          style: theme.textTheme.titleSmall?.copyWith(
            fontFeatures: tabularFigures,
          ),
        ),
        subtitle: Text(
          '${formatDateWithYear(payment.date)} · diezmo de '
          '${formatCentsCompact(payment.grossCupCents)} CUP',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showPaymentDetail(context, payment),
      );
    }

    final offering = offeringValue!;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        child: Icon(
          Icons.favorite_outline,
          size: 20,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
      title: Text(
        formatMoneyCompact(offering.amountCents, offering.currency),
        style: theme.textTheme.titleSmall?.copyWith(
          fontFeatures: tabularFigures,
        ),
      ),
      subtitle: Text(
        [
          'Ofrenda',
          formatDateWithYear(offering.date),
          if (offering.note != null) offering.note!,
        ].join(' · '),
      ),
      onTap: () => showOfferingEditor(context, offering: offering),
      onLongPress: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Borrar esta ofrenda?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Borrar'),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await ref.read(repositoryProvider).deleteOffering(offering.id);
        }
      },
    );
  }
}

