import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../domain/income.dart';
import '../domain/income_draft.dart';
import '../domain/salary_slip.dart';
import '../ui/format.dart';
import '../ui/income_editor.dart';
import 'providers.dart';

/// Recoge los slips de nómina que se comparten con la app desde Telegram.
///
/// Se eligió compartir en vez de leer las notificaciones porque un slip es un
/// mensaje largo: Android puede truncarlo en la notificación justo antes de la
/// línea que importa, y leer notificaciones exige permiso sobre **todas** las
/// del teléfono. Compartir cuesta un toque y entrega el texto entero, siempre.
class SlipIntake extends ConsumerStatefulWidget {
  const SlipIntake({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SlipIntake> createState() => _SlipIntakeState();
}

class _SlipIntakeState extends ConsumerState<SlipIntake> {
  StreamSubscription<List<SharedMediaFile>>? _subscription;

  @override
  void initState() {
    super.initState();

    // Con la app ya abierta.
    _subscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      _onShared,
      onError: (_) {},
    );

    // Y lo que la abrió, si venía de un "compartir".
    ReceiveSharingIntent.instance.getInitialMedia().then((shared) {
      _onShared(shared);
      ReceiveSharingIntent.instance.reset();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onShared(List<SharedMediaFile> shared) {
    final text = shared
        .where((f) => f.type == SharedMediaType.text)
        .map((f) => f.path)
        .join('\n')
        .trim();

    if (text.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => importText(ref, text));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Parsea un texto compartido o pegado y abre el formulario ya relleno.
///
/// Devuelve false si el texto no era un slip, para que quien lo llame pueda
/// decir algo distinto según si el usuario lo pidió a propósito o no.
Future<bool> importText(WidgetRef ref, String text) async {
  final context = ref.context;

  if (!SalarySlipParser.looksLikeSlip(text)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eso no parece un slip de nómina.'),
        ),
      );
    }
    return false;
  }

  final slip = SalarySlipParser.parse(text);

  if (slip.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Es un slip, pero no se encontró ni el Final Pay ni el importe '
            'en USD.',
          ),
        ),
      );
    }
    return false;
  }

  // Antes de nada, mirar si ese mismo slip ya entró. Duplicar un salario
  // entero en silencio sería el peor fallo posible en una app de dinero.
  final key = slip.sourceKey;
  if (key != null) {
    final existing = await ref.read(repositoryProvider).incomeBySource(key);
    if (existing != null) {
      if (!context.mounted) return false;
      final replace = await _askAboutDuplicate(context, existing, slip);
      if (replace != true) return false;
      await ref.read(repositoryProvider).deleteIncome(existing.id);
    }
  }

  if (!context.mounted) return false;

  await showIncomeEditor(
    context,
    draft: IncomeDraft(
      // Hoy, que es cuando llega el slip. El período va en el concepto: si se
      // fechara al cierre de la quincena, un slip que llega con retraso
      // entraría marcado como atrasado cada vez que se hubiera pagado el
      // diezmo entre medias.
      date: DateTime.now(),
      concept: slip.conceptLabel(),
      lines: slip.lines,
      sourceKey: key,
    ),
  );

  return true;
}

Future<bool?> _askAboutDuplicate(
  BuildContext context,
  Income existing,
  SalarySlip slip,
) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Ese slip ya está registrado'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ya hay un ingreso de ${slip.conceptLabel().toLowerCase()}:'),
        const SizedBox(height: 8),
        Text(
          existing.lines
              .map((l) => formatMoneyCompact(l.amountCents, l.currency))
              .join(' + '),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          'registrado el ${formatDateWithYear(existing.date)}'
          '${existing.isPending ? '' : ', y ya diezmado'}.',
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Dejarlo como está'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Reemplazar'),
      ),
    ],
  ),
);
