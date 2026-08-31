import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:thites/app/providers.dart';
import 'package:thites/data/database.dart';
import 'package:thites/data/tithe_repository.dart';
import 'package:thites/domain/currency.dart';
import 'package:thites/domain/income.dart';
import 'package:thites/ui/history_screen.dart';
import 'package:thites/ui/home_screen.dart';
import 'package:thites/ui/payment_screen.dart';
import 'package:thites/ui/theme.dart';

/// Renderiza pantallas a PNG con datos de ejemplo, para poder mirarlas sin
/// desplegar en un teléfono.
///
/// ```
/// flutter test tool/preview_screens.dart
/// ```
///
/// No es un test de verdad —no comprueba nada— pero atrapa lo que ningún test
/// atrapa: que algo se solape, se salga o simplemente se vea mal.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
    await _loadFonts();
  });

  testWidgets('historial', (tester) async {
    await _capture(
      tester,
      const HistoryScreen(),
      'build/preview/historial.png',
    );
  });

  testWidgets('inicio', (tester) async {
    await _capture(tester, const HomeScreen(), 'build/preview/inicio.png');
  });

  testWidgets('pago', (tester) async {
    await _capture(tester, const PaymentScreen(), 'build/preview/pago.png');
  });
}

const _size = Size(411, 915); // Un Pixel 6 en puntos lógicos.

Future<void> _capture(
  WidgetTester tester,
  Widget screen,
  String path,
) async {
  final db = AppDatabase(NativeDatabase.memory());
  final repo = TitheRepository(db);
  await _seed(repo);

  tester.view.physicalSize = _size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: RepaintBoundary(key: _boundary, child: screen),
      ),
    ),
  );

  // Los streams de Drift tardan un par de vueltas en llegar.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }

  await tester.runAsync(() async {
    final boundary =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('escrito $path');
  });

  await db.close();
}

final _boundary = GlobalKey();

/// Datos que se parecen a los de verdad: dos quincenas al mes, alguna ofrenda y
/// varios meses de historia, que es cuando la pantalla tiene algo que enseñar.
Future<void> _seed(TitheRepository repo) async {
  await repo.setTitheBasisPoints(1000);
  await repo.saveDownloadedRates(
    values: const {
      Currency.usd: 67500,
      Currency.eur: 77000,
      Currency.mlc: 43311,
    },
    asOf: DateTime(2026, 8, 31),
  );
  await repo.saveTemplate(
    name: 'Salario',
    concept: 'Salario {quincena}',
    lines: const [
      IncomeLine(amountCents: 2560650, currency: Currency.cup),
      IncomeLine(amountCents: 20000, currency: Currency.usd),
    ],
  );

  var mes = 3;
  for (final bruto in [8100000, 8300000, 8250000, 8600000, 8400000, 9300000]) {
    for (final dia in [7, 21]) {
      final diezmo = (bruto ~/ 2 * 0.1).round();
      await repo.registerPayment(
        date: DateTime(2026, mes, dia),
        ratesUsed: const {Currency.usd: 67500},
        grossCupCents: bruto ~/ 2,
        computedCupCents: diezmo,
        actualCupCents: (diezmo / 100).ceil() * 100,
        titheBasisPoints: 1000,
        incomeIds: const [],
      );
    }
    mes++;
  }

  await repo.saveOffering(
    date: DateTime(2026, 8, 10),
    amountCents: 200000,
    currency: Currency.cup,
    note: 'Misión',
  );
  await repo.saveOffering(
    date: DateTime(2026, 7, 15),
    amountCents: 2000,
    currency: Currency.usd,
    note: null,
  );

  // Y algo pendiente, para que la pantalla de inicio no salga vacía.
  await repo.saveIncome(
    date: DateTime(2026, 8, 20),
    concept: 'Salario 1–15 ago',
    lines: const [
      IncomeLine(amountCents: 2560650, currency: Currency.cup),
      IncomeLine(amountCents: 20000, currency: Currency.usd),
      IncomeLine(amountCents: 10000, currency: Currency.usd),
    ],
  );
}

Future<void> _loadFonts() async {
  // Sin esto los tests dibujan cada letra como una caja negra y la captura no
  // sirve para nada.
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;

  final fonts = {
    'Roboto': ['roboto-regular.ttf', 'roboto-medium.ttf', 'roboto-bold.ttf'],
    'MaterialIcons': ['materialicons-regular.otf'],
  };

  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    var loaded = false;
    for (final name in entry.value) {
      final file = File('$root/bin/cache/artifacts/material_fonts/$name');
      if (!file.existsSync()) continue;
      loader.addFont(
        file.readAsBytes().then((b) => ByteData.view(b.buffer)),
      );
      loaded = true;
    }
    if (loaded) await loader.load();
  }
}
