import 'dart:math';

import 'package:flutter/material.dart';

/// Paketsiz konfetti overlay — yutuq animatsiyasi uchun.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.colors, this.onDone});

  final List<Color> colors;
  final VoidCallback? onDone;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _Particle {
  const _Particle({
    required this.startX,
    required this.startY,
    required this.drift,
    required this.speed,
    required this.rotSpeed,
    required this.rotPhase,
    required this.size,
    required this.color,
  });

  /// Ekran eni ulushi (0..1).
  final double startX;

  /// Ekran balandligi ulushi (-0.1..0).
  final double startY;

  /// Gorizontal sinusoidal drift amplitudasi (ekran eni ulushi).
  final double drift;

  /// Tushish tezligi (ekran balandligi/s).
  final double speed;

  final double rotSpeed;
  final double rotPhase;

  /// Zarra o'lchami pikselda (6..12).
  final double size;

  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.particles,
    required this.t,
    required this.opacity,
  });

  final List<_Particle> particles;

  /// Animatsiya vaqti (0..1).
  final double t;

  final double opacity;

  static const double _gravity = 0.6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final x =
          (p.startX + p.drift * sin(2 * pi * t + p.rotPhase)) * size.width;
      final y =
          (p.startY + p.speed * t + 0.5 * _gravity * t * t) * size.height;

      if (y > size.height) continue;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotSpeed * t * 2 * pi + p.rotPhase);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.55),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.t != t || old.opacity != opacity;
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  static const int _totalMs = 1800;
  static const int _fadeStartMs = 1500;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    final rng = Random();
    _particles = List.generate(80, (_) {
      return _Particle(
        startX: rng.nextDouble(),
        startY: -0.1 * rng.nextDouble(),
        drift: (rng.nextDouble() - 0.5) * 0.14,
        speed: 0.45 + rng.nextDouble() * 0.55,
        rotSpeed: 1.0 + rng.nextDouble() * 3.0,
        rotPhase: rng.nextDouble() * 2 * pi,
        size: 6.0 + rng.nextDouble() * 6.0,
        color: widget.colors[rng.nextInt(widget.colors.length)],
      );
    });

    _ctrl.forward().whenComplete(() => widget.onDone?.call());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final fadeStart = _fadeStartMs / _totalMs;
          final opacity = t > fadeStart
              ? 1.0 - (t - fadeStart) / (1.0 - fadeStart)
              : 1.0;
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              particles: _particles,
              t: t,
              opacity: opacity.clamp(0.0, 1.0),
            ),
          );
        },
      ),
    );
  }
}
