import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/slip_intake.dart';
import 'data/update_service.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Sin esto los nombres de mes y las fechas salen en inglés.
  await initializeDateFormatting('es');
  // La descarga de actualizaciones la lleva el servicio de Android, así que su
  // notificación se configura antes de que pueda arrancar ninguna.
  await UpdateService.configureDownloads();
  runApp(const ProviderScope(child: ThitesApp()));
}

class ThitesApp extends StatelessWidget {
  const ThitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diezmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SlipIntake(child: HomeScreen()),
    );
  }
}
