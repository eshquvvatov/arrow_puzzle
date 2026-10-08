import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/arrow_line.dart';
import '../../theme/palettes.dart';

/// Doska kataklarini piksellarga o'girish geometriyasi.
class BoardGeometry {
  BoardGeometry(Size size, this.cols, this.rows)
      : cellSize = math.min(size.width / cols, size.height / rows) {
    origin = Offset(
      (size.width - cellSize * cols) / 2,
      (size.height - cellSize * rows) / 2,
    );
  }

  final int cols;
  final int rows;
  final double cellSize;
  late final Offset origin;

  Offset center(math.Point<int> c) =>
      origin + Offset((c.x + 0.5) * cellSize, (c.y + 0.5) * cellSize);

  Rect get boardRect =>
      Rect.fromLTWH(origin.dx, origin.dy, cellSize * cols, cellSize * rows);
}

/// Harakatdagi (chiqayotgan yoki to'qnashib qaytayotgan) chiziq.
class MovingLine {
  MovingLine({required this.line, required this.offsetCells});

  final ArrowLine line;

  /// Chiziq o'z yo'li bo'ylab necha katakka oldinga siljigani.
  final double offsetCells;
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.cols,
    required this.rows,
    required this.staticLines,
    required this.movingLines,
    required this.hintId,
    required this.hintPulse,
    required this.blockerIds,
    required this.palette,
    required this.pressedId,
  });

  final int cols;
  final int rows;
  final List<ArrowLine> staticLines;
  final List<MovingLine> movingLines;
  final int? hintId;
  final double hintPulse;
  final Set<int> blockerIds;
  final Palette palette;
  final int? pressedId;

  @override
  void paint(Canvas canvas, Size size) {
    final geo = BoardGeometry(size, cols, rows);
    canvas.save();
    canvas.clipRect(geo.boardRect.inflate(geo.cellSize * 0.45));

    // a) Nuqtalar: barcha kataklar markazida nozik nuqta (to'r ko'rinishi).
    final dotPaint = Paint()
      ..color = palette.line.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    for (var col = 0; col < cols; col++) {
      for (var row = 0; row < rows; row++) {
        final center = geo.center(math.Point<int>(col, row));
        canvas.drawCircle(center, geo.cellSize * 0.045, dotPaint);
      }
    }

    // b) Yo'lak: bosilgan chiziq uchun strelka yo'nalishida doska chetigacha.
    if (pressedId != null) {
      final matches = staticLines.where((l) => l.id == pressedId);
      if (matches.isNotEmpty) {
        final line = matches.first;
        final cs = geo.cellSize;
        final headCenter = geo.center(line.head);
        final d = line.direction;
        final left = d.dx < 0 ? geo.boardRect.left : headCenter.dx - cs / 2;
        final top = d.dy < 0 ? geo.boardRect.top : headCenter.dy - cs / 2;
        final right = d.dx > 0 ? geo.boardRect.right : headCenter.dx + cs / 2;
        final bottom = d.dy > 0 ? geo.boardRect.bottom : headCenter.dy + cs / 2;
        final trackRect = Rect.fromLTRB(left, top, right, bottom);
        final trackPaint = Paint()
          ..color = palette.accent.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(trackRect, Radius.circular(cs * 0.3)),
          trackPaint,
        );
      }
    }

    for (final line in staticLines) {
      var color = palette.line;
      if (line.id == pressedId) {
        color = Color.lerp(palette.line, palette.accent, 0.5)!;
      } else if (blockerIds.contains(line.id)) {
        color = Color.lerp(palette.line, dangerColor, 0.8)!;
      } else if (line.id == hintId) {
        color =
            Color.lerp(palette.line, palette.accent, 0.35 + 0.65 * hintPulse)!;
      }
      _drawLine(canvas, geo, line, 0, color);
    }
    for (final m in movingLines) {
      _drawLine(canvas, geo, m.line, m.offsetCells, palette.line);
    }

    canvas.restore();
  }

  void _drawLine(Canvas canvas, BoardGeometry geo, ArrowLine line,
      double offsetCells, Color color) {
    final cs = geo.cellSize;

    // Trek: chiziq yo'li + strelka yo'nalishida siljishga yetarli davomi.
    // Chiziq trek bo'ylab sirg'aladigan "oyna" sifatida chiziladi — shunda
    // chiqish animatsiyasida tana burilishlarni relsdagidek kuzatib boradi.
    final headCenter = geo.center(line.head);
    final d = line.direction;
    final ext = (offsetCells + 2) * cs;
    final track = Path()..moveTo(geo.center(line.cells.first).dx,
        geo.center(line.cells.first).dy);
    for (final c in line.cells.skip(1)) {
      final p = geo.center(c);
      track.lineTo(p.dx, p.dy);
    }
    track.lineTo(headCenter.dx + d.dx * ext, headCenter.dy + d.dy * ext);

    final metric = track.computeMetrics().first;
    final bodyLen = (line.cells.length - 1) * cs;
    final startD = offsetCells * cs;
    final endD = math.min(startD + bodyLen, metric.length - 0.01);
    if (endD <= startD) return;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cs * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(metric.extractPath(startD, endD), stroke);

    final tangent = metric.getTangentForOffset(endD);
    if (tangent != null) {
      final v = tangent.vector;
      _drawArrowHead(canvas, tangent.position, math.atan2(v.dy, v.dx), cs, color);
    }
  }

  void _drawArrowHead(
      Canvas canvas, Offset pos, double angle, double cs, Color color) {
    final s = cs * 0.40;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    final head = Path()
      ..moveTo(s, 0)
      ..lineTo(-s * 0.35, s * 0.55)
      ..lineTo(-s * 0.15, 0)
      ..lineTo(-s * 0.35, -s * 0.55)
      ..close();
    canvas.drawPath(head, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
