import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Genera los PNG del icono de la app.
///
/// Se ejecuta como test porque así hay un canvas de Flutter de verdad
/// disponible, sin depender de herramientas externas de imagen:
///
/// ```
/// flutter test tool/generate_icon.dart
/// dart run flutter_launcher_icons
/// ```
///
/// La marca es un círculo con una décima parte separada: el diezmo, dicho sin
/// palabras.
void main() {
  testWidgets('genera los iconos', (tester) async {
    // runAsync es obligatorio: los tests corren con un reloj falso y
    // `Picture.toImage` nunca completaría dentro de él.
    await tester.runAsync(() async {
      await _write('assets/icon/icon.png', 1024, withBackground: true);
      await _write(
        'assets/icon/icon_foreground.png',
        1024,
        withBackground: false,
        scale: 0.62,
      );
    });
  });
}

const _background = Color(0xFF14372E);
const _wheel = Color(0xFFF3EFE6);
const _tenth = Color(0xFF4FBF9A);

Future<void> _write(
  String path,
  int size, {
  required bool withBackground,
  double scale = 0.68,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );

  if (withBackground) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      Paint()..color = _background,
    );
  }

  _paintMark(canvas, size.toDouble(), scale);

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  // ignore: avoid_print
  print('escrito $path');
}

void _paintMark(Canvas canvas, double size, double scale) {
  // La porción separada sobresale por arriba, así que la marca entera se baja
  // un poco para que quede ópticamente centrada.
  final center = Offset(size / 2, size / 2 + size * 0.025);
  final radius = size * scale / 2;

  // Un décimo de vuelta: 36 grados.
  const tenth = 2 * math.pi / 10;
  // El hueco tiene que seguir viéndose a 48 píxeles, no solo a 1024.
  const gap = 0.075;

  // Los nueve décimos que se quedan.
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius),
    -math.pi / 2 + tenth / 2 + gap,
    2 * math.pi - tenth - gap * 2,
    true,
    Paint()..color = _wheel,
  );

  // El décimo que se aparta, desplazado hacia arriba para que se lea como una
  // porción que sale del conjunto.
  final offset = Offset(center.dx, center.dy - radius * 0.12);
  canvas.drawArc(
    // Un pelín más pequeña, para que el arco exterior no desborde la silueta
    // del disco.
    Rect.fromCircle(center: offset, radius: radius * 0.96),
    -math.pi / 2 - tenth / 2 - gap,
    tenth,
    true,
    Paint()..color = _tenth,
  );
}
