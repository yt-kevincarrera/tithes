import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app/providers.dart';
import '../app/update_controller.dart';
import '../data/backup_service.dart';
import '../data/income_announcer.dart';
import '../domain/currency.dart';
import 'format.dart';
import 'rate_editor.dart';
import 'template_editor.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final basisPoints = ref.watch(titheBasisPointsProvider).valueOrNull ?? 1000;
    final templates = ref.watch(templatesProvider).valueOrNull ?? const [];
    final endpoint = ref.watch(ratesEndpointProvider).valueOrNull ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _SectionTitle('Cálculo'),
          ListTile(
            title: const Text('Porcentaje del diezmo'),
            subtitle: const Text('Lo normal es 10 %'),
            trailing: Text(
              formatBasisPoints(basisPoints),
              style: theme.textTheme.titleMedium,
            ),
            onTap: () => _editPercent(context, ref, basisPoints),
          ),
          ListTile(
            title: const Text('Tasas de cambio'),
            subtitle: const Text('Ver, refrescar o escribirlas a mano'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showRateEditor(context),
          ),
          ListTile(
            title: const Text('Servidor de tasas'),
            subtitle: Text(
              endpoint.isEmpty ? 'Sin configurar' : endpoint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editEndpoint(context, ref, endpoint),
          ),
          const _TokenExpiryTile(),

          const Divider(height: 32),
          _SectionTitle('Plantillas'),
          if (templates.isEmpty)
            const ListTile(
              subtitle: Text(
                'Sin plantillas todavía. Crea una para registrar el salario '
                'de un toque.',
              ),
            )
          else
            for (final template in templates)
              ListTile(
                title: Text(template.name),
                subtitle: Text(
                  template.lines
                      .map(
                        (l) => formatMoneyCompact(l.amountCents, l.currency),
                      )
                      .join(' + '),
                ),
                onTap: () => showTemplateEditor(context, template: template),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref
                      .read(repositoryProvider)
                      .deleteTemplate(template.id),
                ),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () => showTemplateEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva plantilla'),
            ),
          ),

          const Divider(height: 32),
          _SectionTitle('Copia de seguridad'),
          ListTile(
            title: const Text('Exportar'),
            subtitle: const Text(
              'Un archivo JSON con todo. Guárdalo donde no se pierda.',
            ),
            trailing: const Icon(Icons.ios_share),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            title: const Text('Importar'),
            subtitle: const Text('Reemplaza todos los datos actuales'),
            trailing: const Icon(Icons.file_open_outlined),
            onTap: () => _import(context, ref),
          ),

          const Divider(height: 32),
          _SectionTitle('Avisar a otra app'),
          const _AnnounceTile(),

          const Divider(height: 32),
          _SectionTitle('Actualizaciones'),
          const _UpdateTile(),

          const Divider(height: 32),
          _SectionTitle('Acerca de'),
          const ListTile(
            title: Text('Tasas de cambio'),
            subtitle: Text(
              'Los valores del mercado informal son de elTOQUE '
              '(eltoque.com) y son referenciales.',
            ),
          ),
          const ListTile(
            title: Text('Dónde están tus datos'),
            subtitle: Text(
              'Solo en este teléfono. No se suben a ningún sitio ni hay '
              'cuentas de por medio.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editPercent(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final controller = TextEditingController(text: '${current / 100}');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Porcentaje del diezmo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '%'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    // El porcentaje se guarda en puntos básicos: "12,5 %" son 1250.
    final cents = parseAmountToCents(result);
    if (cents == null || cents <= 0 || cents > 10000) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pon un porcentaje entre 0 y 100.')),
        );
      }
      return;
    }
    await ref.read(repositoryProvider).setTitheBasisPoints(cents);
  }

  Future<void> _editEndpoint(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Servidor de tasas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'La dirección del proxy que consulta elTOQUE. La app no puede '
              'llamar a elTOQUE directamente desde Cuba.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://…/api/rates',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    await ref.read(repositoryProvider).setRatesEndpoint(result);
    await ref.read(ratesRefresherProvider.notifier).refresh();
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final json = await BackupService(ref.read(databaseProvider)).export();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/diezmo-$stamp.json');
    await file.writeAsString(json);

    if (!context.mounted) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'Respaldo de diezmo',
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Importar un respaldo?'),
        content: const Text(
          'Se borrará todo lo que hay ahora y se pondrá el contenido del '
          'archivo. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    final file = await FilePicker.pickFile();
    if (file == null) return;

    try {
      // utf8.decode y no String.fromCharCodes: los conceptos y las notas
      // llevan tildes y eñes.
      final content = utf8.decode(await file.readAsBytes());
      await BackupService(ref.read(databaseProvider)).import(content);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respaldo importado.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo importar: $error')));
      }
    }
  }
}

/// Cuándo caduca el token de elTOQUE.
///
/// Un token caducado no rompe la app —se sigue con las tasas guardadas o
/// escritas a mano— pero sí la deja desactualizada en silencio. Como pedir uno
/// nuevo tarda dos o tres días, se avisa con mucha antelación.
class _TokenExpiryTile extends ConsumerWidget {
  const _TokenExpiryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expiry = ref.watch(tokenExpiryProvider).valueOrNull;
    final daysLeft = ref.watch(tokenDaysLeftProvider);

    if (expiry == null || daysLeft == null) return const SizedBox.shrink();

    final expired = daysLeft < 0;
    final urgent = daysLeft <= kTokenWarningDays;

    return ListTile(
      leading: Icon(
        expired
            ? Icons.error_outline
            : urgent
            ? Icons.schedule
            : Icons.verified_outlined,
        color: expired
            ? theme.colorScheme.error
            : urgent
            ? theme.colorScheme.tertiary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        expired
            ? 'El token de elTOQUE caducó'
            : 'Token de elTOQUE: ${_daysText(daysLeft)}',
      ),
      subtitle: Text(
        expired || urgent
            ? 'Pide uno nuevo en tasas-token.eltoque.com y cámbialo en el '
                  'servidor. Tarda dos o tres días en llegar.'
            : 'Caduca el ${formatDateWithYear(expiry)}.',
      ),
      isThreeLine: expired || urgent,
    );
  }
}

String _daysText(int days) => switch (days) {
  0 => 'caduca hoy',
  1 => 'queda 1 día',
  _ => 'quedan $days días',
};

/// Interruptor del aviso para Cashew, con el formato a la vista.
///
/// El formato se enseña porque en Cashew hay que decirle de dónde salen los
/// valores, y no se puede configurar eso a ciegas.
class _AnnounceTile extends ConsumerWidget {
  const _AnnounceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(announceIncomesProvider).valueOrNull ?? false;

    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          value: enabled,
          title: const Text('Notificar cada ingreso'),
          subtitle: const Text(
            'Emite una notificación por cada monto para que Cashew la '
            'capture y cree la transacción.',
          ),
          onChanged: (value) async {
            if (value) {
              final granted = await ref
                  .read(incomeAnnouncerProvider)
                  .requestPermission();
              if (!granted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Android no dio permiso para notificar. Actívalo en '
                        'los ajustes del sistema.',
                      ),
                    ),
                  );
                }
                return;
              }
            }
            await ref.read(repositoryProvider).setAnnounceIncomes(value);
          },
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Así se verá en Cashew:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Salario 1–15 ago', style: theme.textTheme.titleSmall),
                  Text(
                    IncomeAnnouncer.preview(2560650, Currency.cup),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El título es el concepto y el cuerpo el monto, con punto '
                    'decimal y sin separador de miles.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Versión instalada y comprobación manual.
///
/// El aviso automático solo aparece al abrir la app; esto es para cuando el
/// usuario quiere mirar él mismo.
class _UpdateTile extends ConsumerWidget {
  const _UpdateTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentVersionProvider).valueOrNull;
    final state = ref.watch(updateControllerProvider);
    final checking = state.stage == UpdateStage.checking;

    final String subtitle;
    if (checking) {
      subtitle = 'Buscando…';
    } else if (state.error != null) {
      subtitle = state.error!;
    } else if (state.available != null) {
      subtitle = 'Hay una versión ${state.available!.version} disponible';
    } else {
      subtitle = 'Estás en la última versión';
    }

    return Column(
      children: [
        ListTile(
          title: Text('Versión ${current ?? '…'}'),
          subtitle: Text(subtitle),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: OutlinedButton.icon(
            onPressed: checking
                ? null
                : () => ref
                      .read(updateControllerProvider.notifier)
                      .check(silent: false),
            icon: checking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.system_update),
            label: Text(checking ? 'Buscando…' : 'Buscar actualización'),
          ),
        ),
        if (state.available != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: FilledButton.icon(
              onPressed: state.stage == UpdateStage.downloading
                  ? null
                  : () => ref
                        .read(updateControllerProvider.notifier)
                        .downloadAndInstall(),
              icon: const Icon(Icons.download),
              label: Text(
                state.stage == UpdateStage.downloading
                    ? 'Descargando ${(state.progress * 100).round()} %'
                    : 'Instalar ${state.available!.version}',
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
