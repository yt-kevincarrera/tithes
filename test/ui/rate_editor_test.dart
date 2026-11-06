import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thites/app/providers.dart';
import 'package:thites/data/database.dart';
import 'package:thites/data/rates_api.dart';
import 'package:thites/data/tithe_repository.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/income.dart';
import 'package:thites/ui/rate_editor.dart';

void main() {
  for (final currency in Currency.foreign) {
    testWidgets('editar y guardar una tasa manual de ${currency.code} '
        'actualiza el cálculo y sobrevive a una descarga', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = TitheRepository(db);
      addTearDown(db.close);
      await repo.saveIncome(
        date: DateTime(2026, 11, 1),
        concept: 'Ingreso de prueba',
        lines: [IncomeLine(amountCents: 10000, currency: currency)],
      );
      await repo.saveDownloadedRates(
        values: {currency: 44000},
        asOf: DateTime(2026, 11, 1),
      );
      await repo.saveManualRate(currency: currency, rateCents: 45000);
      await repo.setTokenExpiry(DateTime(2026, 1, 1));
      final api = RatesApi(
        client: MockClient((_) async => http.Response('', 502)),
      );
      addTearDown(api.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            ratesApiProvider.overrideWithValue(api),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final calculation = ref
                    .watch(homeSummaryProvider)
                    .valueOrNull
                    ?.calculation;
                return Scaffold(
                  body: Column(
                    children: [
                      Text('Diezmo: ${calculation?.titheCupCents}'),
                      TextButton(
                        onPressed: () => showRateEditor(context),
                        child: const Text('Tasas'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await _settleDatabase(tester);
      expect(find.text('Diezmo: 450000'), findsOneWidget);
      await tester.tap(find.text('Tasas'));
      await _settleDatabase(tester);

      final field = find
          .byType(TextField)
          .at(Currency.foreign.indexOf(currency));
      await tester.enterText(field, '500,50');
      await tester.pump();
      expect(find.text('Cambios sin guardar'), findsOneWidget);
      // Una tasa ya manual también necesita poder guardarse con el botón.
      final save = find.descendant(
        of: find.ancestor(of: field, matching: find.byType(Row)).first,
        matching: find.byIcon(Icons.check),
      );
      expect(
        save,
        findsOneWidget,
        reason: 'El formulario debe permitir guardar la tasa manual editada',
      );
      await tester.ensureVisible(save);
      await tester.tap(save);
      await _settleDatabase(tester);

      expect((await repo.currentRates())!.rateFor(currency), 50050);
      expect(find.text('Diezmo: 500500'), findsOneWidget);
      expect(find.text('Cambios sin guardar'), findsNothing);
      expect(find.text('Tasa manual guardada'), findsOneWidget);

      // El proxy devuelve el mismo error que cuando el token ha caducado.
      await tester.tap(find.byTooltip('Bajar de elToque'));
      await _settleDatabase(tester);
      expect(find.text('El servidor de tasas respondió 502.'), findsOneWidget);
      expect((await repo.currentRates())!.rateFor(currency), 50050);
      expect(find.text('Diezmo: 500500'), findsOneWidget);

      await repo.saveDownloadedRates(
        values: {currency: 70000},
        asOf: DateTime(2026, 11, 6),
      );
      await _settleDatabase(tester);
      expect((await repo.currentRates())!.rateFor(currency), 50050);
      expect(find.text('Diezmo: 500500'), findsOneWidget);

      // Cerrar y abrir confirma que el campo enseña lo persistido.
      final sheetContext = tester.element(find.byType(RateEditor));
      Navigator.of(sheetContext).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tasas'));
      await _settleDatabase(tester);
      final reopened = tester.widget<TextField>(
        find.byType(TextField).at(Currency.foreign.indexOf(currency)),
      );
      expect(reopened.controller!.text, '500.50');
      final restore = find.text('Volver a la de elToque');
      await tester.ensureVisible(restore);
      await tester.tap(restore);
      await _settleDatabase(tester);
      expect((await repo.currentRates())!.rateFor(currency), 70000);
      expect(await repo.manualCurrencies(), isEmpty);
      expect(find.text('Diezmo: 700000'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}

Future<void> _settleDatabase(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}
