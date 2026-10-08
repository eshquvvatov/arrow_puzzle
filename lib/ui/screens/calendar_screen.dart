import 'package:flutter/material.dart';

import '../../game/puzzle_ref.dart';
import '../../generator/level_generator.dart';
import '../../services/dates.dart';
import '../../services/storage.dart';
import '../../theme/palettes.dart';
import 'game_screen.dart';

/// Kunlik boshqotirmalar kalendari: o'tgan kunlarni ham o'ynasa bo'ladi.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month;
  late Difficulty _difficulty = Storage.difficulty;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  Future<void> _openGame(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => GameScreen(puzzle: DailyPuzzle(date, _difficulty))),
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
        final todayKey = Storage.dateKey(today);
        final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;
        final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: Column(
              children: [
                // Sarlavha qatori
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: p.ink),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Kalendar',
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
                // Lokal qiyinlik filtri (Storage'ga yozmaydi)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: Difficulty.values.asMap().entries.map((e) {
                      final idx = e.key;
                      final d = e.value;
                      final selected = d == _difficulty;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: idx > 0 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _difficulty = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Oy navigatsiyasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: p.ink),
                        onPressed: () => setState(() =>
                            _month = DateTime(_month.year, _month.month - 1)),
                      ),
                      Expanded(
                        child: Text(
                          monthTitleUz(_month),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: _isCurrentMonth
                              ? p.ink.withValues(alpha: 0.25)
                              : p.ink,
                        ),
                        onPressed: _isCurrentMonth
                            ? null
                            : () => setState(() => _month =
                                DateTime(_month.year, _month.month + 1)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (final w in weekdayShortUz)
                        Expanded(
                          child: Text(
                            w,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: p.ink.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 7,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: [
                      for (var i = 1; i < firstWeekday; i++)
                        const SizedBox.shrink(),
                      for (var day = 1; day <= daysInMonth; day++)
                        _DayCell(
                          palette: p,
                          date: DateTime(_month.year, _month.month, day),
                          todayKey: todayKey,
                          difficulty: _difficulty,
                          onTap: _openGame,
                        ),
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.palette,
    required this.date,
    required this.todayKey,
    required this.difficulty,
    required this.onTap,
  });

  final Palette palette;
  final DateTime date;
  final int todayKey;
  final Difficulty difficulty;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final key = Storage.dateKey(date);
    final isFuture = key > todayKey;
    final isToday = key == todayKey;
    final completed = Storage.isCompletedFor(date, difficulty);

    Color? bg;
    Color textColor = palette.ink;
    if (completed) {
      bg = palette.accent;
      textColor = Colors.white;
    } else if (isFuture) {
      textColor = palette.ink.withValues(alpha: 0.25);
    }

    return GestureDetector(
      onTap: isFuture ? null : () => onTap(date),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: isToday && !completed
              ? Border.all(color: palette.accent, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              color: textColor,
              fontWeight:
                  isToday || completed ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
