import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/currency.dart';
import '../domain/income.dart';
import '../domain/income_draft.dart';
import '../domain/salary_slip.dart';
import '../ui/format.dart';
import '../ui/income_editor.dart';
import 'providers.dart';

/// Recoge el texto que otra app comparte con esta.
///
/// En la práctica el camino principal es copiar y pegar, porque Telegram no
/// ofrece "compartir" para los mensajes de un canal: da *Reenviar*, que es
/// interno suyo, y *Copiar*. Esto queda para cuando el slip llegue por otra vía
/// —correo, notas, seleccionar el texto a mano— y para no perder el intent si
/// algún día Telegram lo añade.
class SlipIntake extends ConsumerStatefulWidget {
  const SlipIntake({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SlipIntake> createState() => _SlipIntakeState();
}

class _SlipIntakeState extends ConsumerState<SlipIntake> {
  static const _channel = MethodChannel('dev.selector.diezmo/shared_text');

  @override
  void initState() {
    super.initState();

    // Con la app ya abierta, compartir otro texto llega por aquí.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText') {
        _handle(call.arguments as String?);
      }
    });

    // Y esto recoge lo que abrió la app, que el lado nativo guardó mientras
    // Dart todavía no existía.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _handle(await _channel.invokeMethod<String>('takeSharedText'));
      } on PlatformException {
        // En un dispositivo sin el canal nativo simplemente no hay nada que
        // recoger.
      }
    });
  }

  void _handle(String? text) {
    final trimmed = text?.trim() ?? '';
    if (trimmed.isEmpty || !mounted) return;
    importText(ref, trimmed);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Importa el slip que haya en el portapapeles.
///
/// Es el camino principal, no el de repuesto: en Telegram un mensaje de canal
/// se copia, no se comparte.
Future<void> pasteSlipFromClipboard(WidgetRef ref) async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text?.trim() ?? '';
  final context = ref.context;

  if (text.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay nada copiado. Mantén pulsado el slip en Telegram y dale a '
            'Copiar.',
          ),
        ),
      );
    }
    return;
  }

  await importText(ref, text);
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

  if (slip.deductions.isNotEmpty) {
    final detail = slip.deductions
        .map(
          (d) => '${d.label} ${formatMoneyCompact(d.amountCents, Currency.usd)}',
        )
        .join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Descontado del USD: $detail.')),
    );
  }

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
