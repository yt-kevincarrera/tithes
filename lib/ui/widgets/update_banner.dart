import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/update_controller.dart';

/// Aviso de versión nueva.
///
/// Una barra, no un diálogo: la app se abre para registrar un cobro o pagar el
/// diezmo, y una actualización nunca es más urgente que eso.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    if (!state.showBanner) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final update = state.available!;
    final downloading = state.stage == UpdateStage.downloading;
    final installing = state.stage == UpdateStage.installing;

    // El margen inferior importa: sin él la barra queda pegada a la tarjeta de
    // la deuda y parece que se solapan.
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.system_update,
                size: 20,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      installing
                          ? 'Abriendo el instalador…'
                          : downloading
                          ? 'Descargando ${update.version}…'
                          : 'Versión ${update.version} disponible',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    if (!downloading &&
                        !installing &&
                        update.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        update.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!downloading && !installing) ...[
                TextButton(
                  onPressed: () => ref
                      .read(updateControllerProvider.notifier)
                      .downloadAndInstall(),
                  child: const Text('Actualizar'),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(updateControllerProvider.notifier).dismiss(),
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Ahora no',
                ),
              ],
            ],
          ),
          if (downloading) ...[
            const SizedBox(height: 12),
            Padding(
              // La fila de arriba deja hueco a la derecha para los botones; sin
              // esto la barra sobresale por ese lado.
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.progress == 0 ? null : state.progress,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                state.progress == 0
                    ? 'Empezando…'
                    : '${(state.progress * 100).round()} %',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
