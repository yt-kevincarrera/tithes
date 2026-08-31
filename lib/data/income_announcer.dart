import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/currency.dart';
import '../domain/income.dart';

/// Emite una notificación por cada monto de un ingreso, para que otra app
/// —Cashew— la capture y cree la transacción sin teclear nada.
///
/// El formato del cuerpo es deliberadamente pobre: un número con punto decimal,
/// sin separador de miles, y el código de moneda detrás. Cashew deja elegir de
/// dónde salen los valores, y cuanto más simple sea el texto menos posibilidades
/// hay de que su extractor se equivoque.
class IncomeAnnouncer {
  IncomeAnnouncer([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const _channel = AndroidNotificationChannel(
    'ingresos',
    'Ingresos registrados',
    description:
        'Un aviso por cada ingreso, pensado para que otra app de finanzas '
        'lo capture.',
    importance: Importance.defaultImportance,
  );

  Future<void> _ensureReady() async {
    if (_ready) return;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);

    _ready = true;
  }

  /// Pide el permiso de notificaciones. Desde Android 13 hace falta y el
  /// usuario tiene que concederlo explícitamente.
  Future<bool> requestPermission() async {
    await _ensureReady();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Cómo se verá el aviso. Se enseña en Ajustes para poder configurar Cashew
  /// mirándolo, en vez de a ciegas.
  static String preview(int amountCents, Currency currency) =>
      '${_plain(amountCents)} ${currency.code}';

  /// Junta las líneas de la misma moneda en una sola, sumando.
  ///
  /// Un slip con bono trae los 200 USD del salario y los 100 del bono en dos
  /// líneas, y notificarlas por separado crearía dos transacciones distintas de
  /// la misma nómina en la otra app. Dentro de la app sí se quedan separadas:
  /// ahí sirve ver de dónde salió cada importe.
  ///
  /// Se conserva el orden en que aparecen las monedas.
  static List<IncomeLine> mergeByCurrency(List<IncomeLine> lines) {
    final totals = <Currency, int>{};
    for (final line in lines) {
      totals.update(
        line.currency,
        (previous) => previous + line.amountCents,
        ifAbsent: () => line.amountCents,
      );
    }

    return [
      for (final entry in totals.entries)
        IncomeLine(amountCents: entry.value, currency: entry.key),
    ];
  }

  Future<void> announce(Income income) async {
    await _ensureReady();

    final title = income.concept.isEmpty ? 'Ingreso' : income.concept;
    final lines = mergeByCurrency(income.lines);

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      await _plugin.show(
        // Un id por línea y por ingreso: si se emiten dos avisos a la vez, el
        // segundo no puede pisar al primero antes de que Cashew lo lea.
        id: (income.id.hashCode & 0x0fffffff) + i,
        title: title,
        body: preview(line.amountCents, line.currency),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
      );
    }
  }
}

/// 2560650 -> "25606.50". Sin separador de miles y con punto decimal.
String _plain(int cents) {
  final units = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '$units.$fraction';
}
