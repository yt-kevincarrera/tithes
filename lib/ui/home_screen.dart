import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../app/update_controller.dart';
import '../domain/currency.dart';
import '../domain/exchange_rates.dart';
import '../domain/income.dart';
import '../domain/tithe_calculator.dart';
import 'format.dart';
import 'history_screen.dart';
import 'income_editor.dart';
import 'payment_screen.dart';
import 'rate_editor.dart';
import 'settings_screen.dart';
import 'theme.dart';
import 'widgets/update_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Se intenta refrescar al abrir. Si falla no pasa nada: quedan las tasas
    // que ya había guardadas.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ratesRefresherProvider.notifier).refresh();
      // En silencio: si no hay internet o GitHub no responde, no es asunto del
      // usuario y no se le dice nada.
      ref.read(updateControllerProvider.notifier).check();
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(homeSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diezmo'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Historial',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
          ),
        ],
      ),
      body: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(error: error),
        data: (data) => RefreshIndicator(
          onRefresh: () =>
              ref.read(ratesRefresherProvider.notifier).refresh(),
          child: _HomeBody(summary: data),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showIncomeEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Ingreso'),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templatesProvider).valueOrNull ?? const [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const UpdateBanner(),
        _DebtCard(summary: summary),
        const SizedBox(height: 16),
        if (summary.missingRates.isNotEmpty)
          _MissingRatesNotice(missing: summary.missingRates)
        else if (summary.hasPending)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentScreen()),
            ),
            icon: const Icon(Icons.volunteer_activism_outlined),
            label: const Text('Pagar diezmo'),
          ),
        if (templates.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Registrar rápido',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final template in templates)
                ActionChip(
                  avatar: const Icon(Icons.bolt_outlined, size: 18),
                  label: Text(template.name),
                  onPressed: () =>
                      showIncomeEditor(context, template: template),
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _PendingSection(summary: summary),
      ],
    );
  }
}

class _DebtCard extends ConsumerWidget {
  const _DebtCard({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final calculation = summary.calculation;
    final nothingDue = calculation != null && calculation.isEmpty;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nothingDue ? 'Estás al día' : 'Debes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            if (calculation == null)
              Text(
                '—',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatCentsCompact(calculation.proposedCupCents),
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CUP',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            if (calculation != null && !calculation.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${formatBasisPoints(calculation.titheBasisPoints)} de '
                '${formatCentsCompact(calculation.grossCupCents)} CUP pendientes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 16),
              _Breakdown(calculation: calculation),
            ],
            if (nothingDue) ...[
              const SizedBox(height: 4),
              Text(
                summary.lastPayment == null
                    ? 'Todavía no hay ingresos sin diezmar.'
                    : 'Último pago ${formatRelativeDate(summary.lastPayment!.date)}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _RateStatus(rates: summary.rates),
          ],
        ),
      ),
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.calculation});

  final TitheCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: color,
      fontFeatures: tabularFigures,
    );

    return Column(
      children: [
        for (final subtotal in calculation.subtotals)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subtotal.currency == Currency.cup
                        ? formatMoneyCompact(
                            subtotal.amountCents,
                            subtotal.currency,
                          )
                        : '${formatMoneyCompact(subtotal.amountCents, subtotal.currency)}'
                              ' × ${formatRate(subtotal.rateCents)}',
                    style: style,
                  ),
                ),
                Text(formatCentsCompact(subtotal.cupCents), style: style),
              ],
            ),
          ),
      ],
    );
  }
}

class _RateStatus extends ConsumerWidget {
  const _RateStatus({required this.rates});

  final ExchangeRates? rates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final refresh = ref.watch(ratesRefresherProvider);
    final color = theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.75);

    final String label;
    if (refresh.isRefreshing) {
      label = 'Buscando tasas…';
    } else if (rates == null) {
      label = 'Sin tasas todavía';
    } else {
      final origin = switch (rates!.source) {
        RateSource.manual => 'a mano',
        RateSource.api => 'elToque',
        RateSource.cache => 'elToque',
      };
      label = 'Tasa del ${formatRelativeDate(rates!.asOf)} · $origin';
    }

    return Row(
      children: [
        Icon(
          refresh.error != null
              ? Icons.cloud_off_outlined
              : Icons.currency_exchange,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
        TextButton(
          onPressed: () => showRateEditor(context),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
          ),
          child: const Text('Tasas'),
        ),
      ],
    );
  }
}

class _MissingRatesNotice extends StatelessWidget {
  const _MissingRatesNotice({required this.missing});

  final Set<Currency> missing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codes = missing.map((c) => c.code).join(', ');

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Falta la tasa de $codes',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sin ella no se puede calcular la deuda. Escríbela a mano y '
              'sigue adelante.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => showRateEditor(context),
              child: const Text('Escribir tasas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingSection extends ConsumerWidget {
  const _PendingSection({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (!summary.hasPending) {
      return Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Nada pendiente',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Registra un ingreso cuando cobres.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pendiente de diezmar (${summary.pending.length})',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        for (final income in summary.pending)
          IncomeTile(
            income: income,
            isOverdue: TitheCalculator.isOverdue(
              income,
              lastPaymentDate: summary.lastPayment?.date,
            ),
          ),
      ],
    );
  }
}

class IncomeTile extends ConsumerWidget {
  const IncomeTile({
    super.key,
    required this.income,
    this.isOverdue = false,
  });

  final Income income;
  final bool isOverdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(income.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          ref.read(repositoryProvider).deleteIncome(income.id),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onTap: () => showIncomeEditor(context, income: income),
        title: Text(
          income.concept.isEmpty ? 'Ingreso' : income.concept,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Row(
          children: [
            Text(formatRelativeDate(income.date)),
            if (isOverdue) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'atrasado',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final line in income.lines)
              Text(
                formatMoneyCompact(line.amountCents, line.currency),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFeatures: tabularFigures,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar este ingreso?'),
        content: const Text('No se puede deshacer.'),
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
    return confirmed ?? false;
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text('Algo falló al cargar los datos:\n$error'),
    ),
  );
}
