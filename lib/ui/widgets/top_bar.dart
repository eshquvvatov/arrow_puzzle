import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import '../../theme/palettes.dart';

/// Jonlar, progress va hint tugmasi qatori (skrinshotdagi 2-qator).
class GameTopBar extends StatelessWidget {
  const GameTopBar({
    super.key,
    required this.controller,
    required this.hintsLeft,
    required this.onHint,
  });

  final GameController controller;
  final int hintsLeft;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final p = themeController.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (var i = 0; i < GameController.maxLives; i++)
            Icon(
              Icons.water_drop,
              size: 22,
              color: i < controller.lives
                  ? p.life
                  : p.life.withValues(alpha: 0.22),
            ),
          const SizedBox(width: 12),
          Expanded(child: _ProgressBar(value: controller.progress, palette: p)),
          const SizedBox(width: 12),
          _HintButton(
            palette: p,
            count: hintsLeft,
            enabled: hintsLeft > 0 && controller.status == GameStatus.playing,
            onTap: onHint,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.palette});

  final double value;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 22,
            child: LayoutBuilder(builder: (context, cons) {
              return Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: palette.line.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: palette.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (cons.maxWidth - 20) * value.clamp(0.0, 1.0),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.star,
                        size: 14,
                        color: value > 0
                            ? palette.accent
                            : palette.line.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(color: palette.ink, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.palette,
    required this.count,
    required this.enabled,
    required this.onTap,
  });

  final Palette palette;
  final int count;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 28,
            color: enabled
                ? palette.accent
                : palette.ink.withValues(alpha: 0.3),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: enabled
                    ? palette.accent
                    : palette.ink.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
