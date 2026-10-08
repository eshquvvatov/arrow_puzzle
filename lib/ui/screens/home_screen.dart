import 'package:flutter/material.dart';

import '../../game/puzzle_ref.dart';
import '../../generator/level_generator.dart';
import '../../services/dates.dart';
import '../../services/storage.dart';
import '../../theme/palettes.dart';
import '../widgets/theme_picker.dart';
import 'calendar_screen.dart';
import 'game_screen.dart';
import 'levels_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openGame(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => GameScreen(puzzle: DailyPuzzle(date, Storage.difficulty))),
    );
    if (mounted) setState(() {}); // bajarilgan belgini yangilash
  }

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CalendarScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openStats() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openLevels() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LevelsScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final p = themeController.palette;
        final today = DateTime.now();
        final selectedDifficulty = Storage.difficulty;
        final done = Storage.isCompletedFor(today, selectedDifficulty);
        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(Icons.gesture, size: 72, color: p.accent),
                  const SizedBox(height: 12),
                  Text(
                    'Arrow Puzzle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.ink,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Strelkali boshqotirma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: p.ink.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Qiyinlik selektori
                  Row(
                    children: Difficulty.values.asMap().entries.map((e) {
                      final idx = e.key;
                      final d = e.value;
                      final selected = d == selectedDifficulty;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: idx > 0 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () {
                              Storage.setDifficulty(d);
                              setState(() {});
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? p.accent
                                    : p.ink.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                d.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected ? Colors.white : p.ink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Bugungi boshqotirma tugmasi
                  Material(
                    color: p.accent,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _openGame(today),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.today,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bugungi boshqotirma',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatDateUz(today),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (done)
                              const Icon(Icons.check_circle,
                                  color: Colors.white, size: 28),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Levellar kartasi
                  Material(
                    color: p.line,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _openLevels,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Icon(Icons.grid_view,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Levellar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Level ${Storage.nextLevel}',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pastki 3 ta karta
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryCard(
                          palette: p,
                          icon: Icons.calendar_month,
                          label: 'Kalendar',
                          onTap: _openCalendar,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryCard(
                          palette: p,
                          icon: Icons.bar_chart,
                          label: 'Statistika',
                          onTap: _openStats,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryCard(
                          palette: p,
                          icon: Icons.palette_outlined,
                          label: 'Mavzu',
                          onTap: () => showThemePicker(context),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SecondaryCard extends StatelessWidget {
  const _SecondaryCard({
    required this.palette,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Palette palette;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.ink.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: palette.ink, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: palette.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
