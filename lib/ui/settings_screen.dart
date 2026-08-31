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

    return ListTile(
      title: Text('Versión ${current ?? '…'}'),
      subtitle: Text(subtitle),
      trailing: checking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      onTap: checking
          ? null
          : () => ref
                .read(updateControllerProvider.notifier)
                .check(silent: false),
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
