import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import '../../game/puzzle_ref.dart';
import '../../services/sound_service.dart';
import '../../services/storage.dart';
import '../../theme/palettes.dart';
import '../widgets/board_view.dart';
import '../widgets/confetti.dart';
import '../widgets/theme_picker.dart';
import '../widgets/top_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.puzzle});

  final PuzzleRef puzzle;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;

  /// Qayta boshlashda BoardView'ni yangidan qurish uchun kalit.
  int _generation = 0;
  late int _hintsLeft;
  bool _lostShown = false;
  bool _confetti = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
        seed: widget.puzzle.seed, generator: widget.puzzle.generator);
    _controller.addListener(_onGameChanged);
    _hintsLeft = Storage.hintsRemaining(DateTime.now());
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.status == GameStatus.lost && !_lostShown) {
      _lostShown = true;
      // To'qnashuv animatsiyasi tugashini kutamiz.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showLostDialog();
      });
    }
  }

  void _restart() {
    _lostShown = false;
    setState(() {
      _generation++;
      _confetti = false;
    });
    _controller.restart();
  }

  void _onBoardCleared() {
    widget.puzzle.markCompleted();
    soundService.win();
    setState(() => _confetti = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _showWonDialog();
    });
  }

  void _useHint() {
    if (_hintsLeft <= 0) return;
    if (_controller.showHint()) {
      setState(() => _hintsLeft--);
      Storage.setHintsRemaining(DateTime.now(), _hintsLeft);
    }
  }

  void _showWonDialog() {
    final p = themeController.palette;
    final hasNext = widget.puzzle.next != null;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.background,
        title: Text('Barakalla! 🎉', style: TextStyle(color: p.ink)),
        content: Text(
          'Boshqotirma yechildi.',
          style: TextStyle(color: p.ink.withValues(alpha: 0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _restart();
            },
            child: Text("Qayta o'ynash",
                style: TextStyle(color: p.ink.withValues(alpha: 0.7))),
          ),
          if (hasNext)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('Tayyor',
                  style: TextStyle(color: p.ink.withValues(alpha: 0.7))),
            )
          else
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: p.accent),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Tayyor'),
            ),
          if (hasNext)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: p.accent),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        GameScreen(puzzle: widget.puzzle.next!),
                  ),
                );
              },
              child: const Text('Keyingi level'),
            ),
        ],
      ),
    );
  }

  void _showLostDialog() {
    final p = themeController.palette;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.background,
        title: Text('Jonlar tugadi 💧', style: TextStyle(color: p.ink)),
        content: Text(
          "Hechqisi yo'q — yana bir urinib ko'ring!",
          style: TextStyle(color: p.ink.withValues(alpha: 0.75)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Chiqish',
                style: TextStyle(color: p.ink.withValues(alpha: 0.7))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.accent),
            onPressed: () {
              Navigator.pop(ctx);
              _restart();
            },
            child: const Text('Qayta boshlash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final p = themeController.palette;
        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            child: Column(
              children: [
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
                          widget.puzzle.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: p.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.palette_outlined, color: p.ink),
                        onPressed: () => showThemePicker(context),
                      ),
                    ],
                  ),
                ),
                GameTopBar(
                  controller: _controller,
                  hintsLeft: _hintsLeft,
                  onHint: _useHint,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      children: [
                        BoardView(
                          key: ValueKey(_generation),
                          controller: _controller,
                          onBoardCleared: _onBoardCleared,
                        ),
                        if (_confetti)
                          Positioned.fill(
                            child: ConfettiOverlay(
                              colors: [p.accent, p.life, p.line],
                              onDone: () {
                                if (mounted) {
                                  setState(() => _confetti = false);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
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
