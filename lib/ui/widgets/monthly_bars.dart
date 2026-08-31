import 'package:flutter/material.dart';

import '../../domain/history_stats.dart';
import '../../domain/period_label.dart';
import '../format.dart';
import '../theme.dart';

/// Cuánto se entregó cada mes, en barras.
///
/// Un total suelto no dice si vas más o menos que antes; la forma de las barras
/// sí. Se dibuja con cajas normales en vez de con una librería de gráficos:
/// para una docena de barras no compensa arrastrar una dependencia entera.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({super.key, required this.months, this.maxBars = 12});

  final List<MonthlyTotal> months;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    if (months.length < 2) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final visible = months.length > maxBars
        ? months.sublist(months.length - maxBars)
        : months;

    final peak = visible
        .map((m) => m.totalCupCents)
        .reduce((a, b) => a > b ? a : b);
    if (peak == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final month in visible)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _Bar(month: month, peak: peak),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final month in visible)
              Expanded(
                child: Text(
                  monthAbbr(month.month.month),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.month, required this.peak});

  final MonthlyTotal month;
  final int peak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const maxHeight = 96.0;

    // Un mínimo visible: una barra de un píxel no se lee como "poco", se lee
    // como "nada", y son cosas distintas.
    final height = month.totalCupCents == 0
        ? 2.0
        : (month.totalCupCents / peak * maxHeight).clamp(6.0, maxHeight);

    final offeringHeight = month.totalCupCents == 0
        ? 0.0
        : height * (month.offeringCupCents / month.totalCupCents);

    return Tooltip(
      message:
          '${monthAbbr(month.month.month)} ${month.month.year}\n'
          'Diezmo ${formatCentsCompact(month.titheCupCents)} CUP'
          '${month.offeringCupCents > 0 ? '\nOfrendas ${formatCentsCompact(month.offeringCupCents)} CUP' : ''}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Column(
                children: [
                  if (offeringHeight > 0)
                    Container(
                      height: offeringHeight,
                      color: theme.colorScheme.tertiary,
                    ),
                  Expanded(
                    child: Container(color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Un dato del encabezado: etiqueta pequeña arriba, número grande debajo.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.footnote,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? footnote;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style:
                (emphasis
                        ? theme.textTheme.headlineMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabularFigures,
                    ),
          ),
        ),
        if (footnote != null) ...[
          const SizedBox(height: 2),
          Text(
            footnote!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}
