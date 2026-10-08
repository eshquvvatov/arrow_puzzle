// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('generate app icon 1024x1024', (WidgetTester tester) async {
    // tester.runAsync — real async (GPU) operatsiyalar fake-zone tashqarisida.
    await tester.runAsync(() async {
      const double size = 1024;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // --- Fon: #F1E9D6 ---
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, size, size),
        ui.Paint()..color = const ui.Color(0xFFF1E9D6),
      );

      // --- Ilon chizig'i: (256,760)→(256,452)→(548,452)→(548,700)→(760,700) ---
      final linePaint = ui.Paint()
        ..color = const ui.Color(0xFF6B4A32)
        ..strokeWidth = 88
        ..strokeCap = ui.StrokeCap.round
        ..strokeJoin = ui.StrokeJoin.round
        ..style = ui.PaintingStyle.stroke;

      final linePath = ui.Path();
      linePath.moveTo(256, 760);
      linePath.lineTo(256, 452);
      linePath.lineTo(548, 452);
      linePath.lineTo(548, 700);
      linePath.lineTo(760, 700);
      canvas.drawPath(linePath, linePaint);

      // --- Strelka uchi: (760,700)da o'ngga qaragan to'ldirilgan uchburchak ---
      // Uzunlik ~150, balandlik ~170 → yarim balandlik 85
      final arrowPaint = ui.Paint()
        ..color = const ui.Color(0xFFCB7B2B)
        ..style = ui.PaintingStyle.fill;

      final arrowPath = ui.Path();
      arrowPath.moveTo(760 + 150, 700); // uchi
      arrowPath.lineTo(760, 700 - 85); // yuqori burchak
      arrowPath.lineTo(760, 700 + 85); // pastki burchak
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);

      // --- Bezak: (300,260) markazda radius 36 doira #CB7B2B ---
      canvas.drawCircle(
        const ui.Offset(300, 260),
        36,
        ui.Paint()..color = const ui.Color(0xFFCB7B2B),
      );

      // --- PNG ga yozish ---
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      expect(byteData, isNotNull, reason: 'toByteData null qaytardi');

      final iconDir = Directory('assets/icon');
      if (!iconDir.existsSync()) iconDir.createSync(recursive: true);

      final outFile = File('assets/icon/icon.png');
      outFile.writeAsBytesSync(byteData!.buffer.asUint8List());

      expect(outFile.existsSync(), isTrue);
      print('Icon yaratildi: ${outFile.absolute.path} '
          '(${outFile.lengthSync()} bytes), '
          'tasvir: ${size.toInt()}x${size.toInt()}, '
          'diagonal=${math.sqrt(2) * size ~/ 1}px');
    });
  });
}
