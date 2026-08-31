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
    final ready = state.stage == UpdateStage.readyToInstall;

    final title = switch (state.stage) {
      UpdateStage.installing => 'Abriendo el instalador…',
      UpdateStage.downloading => 'Descargando ${update.version}…',
      UpdateStage.readyToInstall => 'Versión ${update.version} lista',
      _ => 'Versión ${update.version} disponible',
    };

    return Container(
      // El margen inferior no es decorativo: sin él la barra queda pegada a la
      // tarjeta de la deuda y parece que se solapan.
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.system_update,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    if (ready) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Descargada. Toca instalar cuando quieras.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ] else if (!downloading &&
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
            ],
          ),

          if (downloading) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.progress == 0 ? null : state.progress,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.progress == 0
                  ? 'Puedes salir de la app: la descarga sigue.'
                  : '${(state.progress * 100).round()} % · puedes salir de la app',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withValues(
                  alpha: 0.8,
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

          // Los botones van en su propia fila, no apretados al lado del texto:
          // con títulos largos se quedaban sin sitio y se montaban encima.
          if (!downloading && !installing) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      ref.read(updateControllerProvider.notifier).dismiss(),
                  child: const Text('Ahora no'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => ref
                      .read(updateControllerProvider.notifier)
                      .downloadAndInstall(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(ready ? 'Instalar' : 'Actualizar'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
