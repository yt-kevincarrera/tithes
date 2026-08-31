import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../domain/date_only.dart';
import '../domain/history_stats.dart';
import '../domain/offering.dart';
import '../domain/payment.dart';
import '../domain/period_label.dart';
import 'format.dart';
import 'offering_editor.dart';
import 'payment_detail.dart';
import 'theme.dart';
import 'widgets/monthly_bars.dart';

/// Los rangos que se pueden mirar.
///
/// No son períodos de verdad —el período real es "desde el último pago"— sino
/// una lente para leer el historial.
enum HistoryRange {
  thisMonth('Este mes'),
  lastMonth('Mes pasado'),
  last6Months('6 meses'),
  thisYear('Este año'),
  all('Todo');

  const HistoryRange(this.label);

  final String label;

  (DateTime?, DateTime?) boundsAt(DateTime now) {
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
      HistoryRange.last6Months => (
        DateTime(today.year, today.month - 5),
        today,
      ),
      HistoryRange.thisYear => (
        DateTime(today.year),
        DateTime(today.year, 12, 31),
      ),
      HistoryRange.all => (null, null),
    };
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryRange _range = HistoryRange.last6Months;

  @override
  Widget build(BuildContext context) {
    final payments = ref.watch(paymentsProvider).valueOrNull ?? const [];
    final offerings = ref.watch(offeringsProvider).valueOrNull ?? const [];
    final rates = ref.watch(ratesProvider).valueOrNull;

    final (from, to) = _range.boundsAt(DateTime.now());
    final stats = HistoryCalculator.compute(
      payments: payments,
      offerings: offerings,
      rates: rates,
      from: from,
      to: to,
    );

    final entries = <_Entry>[
      ...payments.where((p) => _inRange(p.date, from, to)).map(_Entry.payment),
      ...offerings.where((o) => _inRange(o.date, from, to)).map(_Entry.offering),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
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
          ),
          SliverToBoxAdapter(child: _Summary(stats: stats)),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyRange(range: _range),
            )
          else
            ..._buildGroupedEntries(entries, stats),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showOfferingEditor(context),
        icon: const Icon(Icons.favorite_outline),
        label: const Text('Ofrenda'),
      ),
    );
  }

  static bool _inRange(DateTime date, DateTime? from, DateTime? to) {
    final day = dateOnly(date);
    if (from != null && day.isBefore(dateOnly(from))) return false;
    if (to != null && day.isAfter(dateOnly(to))) return false;
    return true;
  }

  /// Agrupa por mes con su total encima.
  ///
  /// Una lista plana de veinte pagos no se lee; con el mes delante y su total
  /// al lado, se puede recorrer de un vistazo.
  List<Widget> _buildGroupedEntries(List<_Entry> entries, HistoryStats stats) {
    final groups = <DateTime, List<_Entry>>{};
    for (final entry in entries) {
      final key = DateTime(entry.date.year, entry.date.month);
      groups.putIfAbsent(key, () => []).add(entry);
    }

    // El total del mes sale de la misma cuenta que la barra del gráfico. Si se
    // sumara aquí a mano, una ofrenda en divisa quedaría fuera y la cabecera
    // diría un número distinto del que dibuja la barra justo encima.
    final totals = {
      for (final month in stats.byMonth) month.month: month.totalCupCents,
    };

    final slivers = <Widget>[];
    for (final group in groups.entries) {
      final total = totals[group.key] ?? 0;

      slivers.add(
        SliverToBoxAdapter(
          child: _MonthHeader(month: group.key, totalCupCents: total),
        ),
      );
      slivers.add(
        SliverList.separated(
          itemCount: group.value.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) =>
              group.value[index].build(context, ref),
        ),
      );
    }
    return slivers;
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.stats});

  final HistoryStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stats.isEmpty) return const SizedBox(height: 8);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatBlock(
            label: 'Diezmo entregado',
            value: '${formatCentsCompact(stats.titheCupCents)} CUP',
            emphasis: true,
            footnote: stats.paymentCount == 1
                ? '1 pago'
                : '${stats.paymentCount} pagos'
                      '${stats.averagePaymentCupCents != null ? ' · media '
                            '${formatCentsCompact(stats.averagePaymentCupCents!)}' : ''}',
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Ofrendas',
                  value: '${formatCentsCompact(stats.offeringCupCents)} CUP',
                  footnote: [
                    stats.offeringCount == 1
                        ? '1 ofrenda'
                        : '${stats.offeringCount} ofrendas',
                    if (stats.offeringsAreApproximate) 'a tasa de hoy',
                  ].join(' · '),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatBlock(
                  label: 'Ingresos diezmados',
                  value: '${formatCentsCompact(stats.grossCupCents)} CUP',
                  footnote: stats.effectiveBasisPoints == null
                      ? null
                      : 'entregaste el '
                            '${formatBasisPoints(stats.effectiveBasisPoints!)}',
                ),
              ),
            ],
          ),
          if (stats.byMonth.length >= 2) ...[
            const SizedBox(height: 24),
            MonthlyBars(months: stats.byMonth),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(
                  color: theme.colorScheme.primary,
                  label: 'Diezmo',
                ),
                const SizedBox(width: 16),
                _LegendDot(
                  color: theme.colorScheme.tertiary,
                  label: 'Ofrendas',
                ),
              ],
            ),
          ],
          if (stats.lastPayment != null) ...[
            const SizedBox(height: 16),
            Text(
              'Último pago ${formatRelativeDate(stats.lastPayment!)}.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.totalCupCents});

  final DateTime month;
  final int totalCupCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thisYear = month.year == DateTime.now().year;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              thisYear
                  ? monthAbbr(month.month).toUpperCase()
                  : '${monthAbbr(month.month).toUpperCase()} ${month.year}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Text(
            '${formatCentsCompact(totalCupCents)} CUP',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontFeatures: tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRange extends StatelessWidget {
  const _EmptyRange({required this.range});

  final HistoryRange range;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 44,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            range == HistoryRange.all
                ? 'Todavía no has registrado ningún pago.'
                : 'Nada en "${range.label.toLowerCase()}".',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
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
          'Diezmo · ${formatDate(payment.date)} · sobre '
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
          formatDate(offering.date),
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
