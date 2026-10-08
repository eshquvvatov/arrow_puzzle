import 'package:flutter/material.dart';

import '../../generator/level_generator.dart';
import '../../services/stats.dart';
import '../../services/storage.dart';
import '../../theme/palettes.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final p = themeController.palette;
        final allDays = Storage.allCompletedDays;
        final streak = currentStreak(allDays, DateTime.now());
        final longest = longestStreak(allDays);
        final total = Difficulty.values.fold<int>(
          0,
          (sum, d) => sum + Storage.completedDaysFor(d).length,
        );

        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sarlavha qatori
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: p.ink),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Statistika',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Kontent
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Ikkita seriya kartasi yonma-yon
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              palette: p,
                              icon: Icons.local_fire_department,
                              value: '$streak',
                              unit: 'kun',
                              label: 'Joriy seriya',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              palette: p,
                              icon: Icons.emoji_events,
                              value: '$longest',
                              unit: 'kun',
                              label: 'Eng uzun seriya',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Jami yechilgan karta
                      _TotalCard(palette: p, total: total),
                      const SizedBox(height: 8),
                      // Levellar qatori
                      _LevelsRow(palette: p),
                      const SizedBox(height: 16),
                      // Har qiyinlik uchun qator
                      for (final d in Difficulty.values) ...[
                        _DifficultyRow(palette: p, difficulty: d),
                        if (d != Difficulty.values.last) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.palette,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  final Palette palette;
  final IconData icon;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: palette.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: palette.accent, size: 28),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: palette.accent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    color: palette.ink.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.ink.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.palette, required this.total});

  final Palette palette;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: palette.ink.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: palette.accent, size: 24),
          const SizedBox(width: 12),
          Text(
            'Jami yechilgan:',
            style: TextStyle(color: palette.ink, fontSize: 16),
          ),
          const Spacer(),
          Text(
            '$total',
            style: TextStyle(
              color: palette.accent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelsRow extends StatelessWidget {
  const _LevelsRow({required this.palette});

  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final solved = Storage.completedLevels.length;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: palette.ink.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'Levellar',
            style: TextStyle(color: palette.ink, fontSize: 15),
          ),
          const Spacer(),
          Text(
            '$solved ta yechilgan',
            style: TextStyle(
              color: palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyRow extends StatelessWidget {
  const _DifficultyRow({required this.palette, required this.difficulty});

  final Palette palette;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final count = Storage.completedDaysFor(difficulty).length;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: palette.ink.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            difficulty.label,
            style: TextStyle(color: palette.ink, fontSize: 15),
          ),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              color: palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
