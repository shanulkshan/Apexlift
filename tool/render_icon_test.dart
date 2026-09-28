// Renders the launcher-icon source PNGs from OxMarkPainter.
//
//   flutter test tool/render_icon_test.dart
//   dart run flutter_launcher_icons
//
// Lives outside test/ so it doesn't run with the normal test suite.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxlift/core/theme/app_colors.dart';
import 'package:oxlift/core/widgets/ox_logo.dart';

const _size = 1024.0;

Future<void> _write(String path, void Function(Canvas canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final image = await recorder.endRecording().toImage(_size.toInt(), _size.toInt());
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  testWidgets('render launcher icon sources', (tester) async {
    await tester.runAsync(() async {
      // Full-bleed square icon (iOS and legacy Android). The OS applies its
      // own corner mask, so no rounding here; the mark is inset so the horn
      // tips stay clear of the rounded corners.
      await _write('assets/brand/icon.png', (canvas) {
        canvas.drawRect(Offset.zero & const Size.square(_size), Paint()..color = AppColors.ink);
        const scale = 0.84;
        canvas.translate(_size * (1 - scale) / 2, _size * (1 - scale) / 2 + _size * 0.02);
        canvas.scale(scale);
        OxMarkPainter().paint(canvas, const Size.square(_size));
      });

      // Android adaptive-icon foreground: transparent, mark shrunk into the
      // central safe zone so launcher masks (circle, squircle) never clip it.
      await _write('assets/brand/icon_foreground.png', (canvas) {
        const scale = 0.66;
        canvas.translate(_size * (1 - scale) / 2, _size * (1 - scale) / 2 + _size * 0.02);
        canvas.scale(scale);
        OxMarkPainter().paint(canvas, const Size.square(_size));
      });
    });
  });
}
