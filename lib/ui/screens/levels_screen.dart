import 'package:flutter/material.dart';

import '../../game/puzzle_ref.dart';
import '../../services/storage.dart';
import '../../theme/palettes.dart';
import 'game_screen.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  Future<void> _openLevel(int n) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(puzzle: LevelPuzzle(n)),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final p = themeController.palette;
        final completedLevels = Storage.completedLevels;
        final nextLevel = Storage.nextLevel;
        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: Column(
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
                          'Levellar',
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
                // Level panjarachalari (300 ta — keyinchalik oshirish oson)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 300,
                    itemBuilder: (context, index) {
                      final n = index + 1;
                      return _LevelCell(
                        palette: p,
                        n: n,
                        completedLevels: completedLevels,
                        nextLevel: nextLevel,
                        onTap: _openLevel,
                      );
                    },
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

class _LevelCell extends StatelessWidget {
  const _LevelCell({
    required this.palette,
    required this.n,
    required this.completedLevels,
    required this.nextLevel,
    required this.onTap,
  });

  final Palette palette;
  final int n;
  final Set<int> completedLevels;
  final int nextLevel;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSolved = completedLevels.contains(n);
    final isNext = n == nextLevel;

    final Color bgColor;
    final BoxBorder? border;
    if (isSolved) {
      bgColor = palette.accent;
      border = null;
    } else if (isNext) {
      bgColor = Colors.transparent;
      border = Border.all(color: palette.accent, width: 2.5);
    } else {
      bgColor = palette.ink.withValues(alpha: 0.06);
      border = null;
    }

    return GestureDetector(
      onTap: () => onTap(n),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: border,
        ),
        child: Center(
          child: Text(
            '$n',
            style: TextStyle(
              color: isSolved ? Colors.white : palette.ink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
