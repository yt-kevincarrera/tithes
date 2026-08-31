import 'package:flutter/material.dart';

/// Estructura común de las hojas inferiores: agarradera, título, contenido
/// desplazable y hueco para el teclado.
///
/// Vive aparte porque el manejo del teclado es fácil de hacer mal y no quería
/// repetirlo en cada formulario.
class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: theme.textTheme.titleLarge),
                  ),
                  ...actions,
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
