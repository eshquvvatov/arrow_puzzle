import 'dart:math';

import 'package:flutter/foundation.dart';

import '../generator/level_generator.dart';
import '../models/arrow_line.dart';
import '../models/board.dart';

enum GameStatus { playing, won, lost }

/// Strelkaga bosish natijasi — UI shu asosida animatsiya tanlaydi.
class TapResult {
  TapResult.removed(this.line, this.ray)
      : removed = true,
        blockIndex = null,
        blockerId = null;

  TapResult.blocked(this.line, this.ray, this.blockIndex, this.blockerId)
      : removed = false;

  final ArrowLine line;
  final bool removed;
  final List<Point<int>> ray;

  /// Nurda to'sqinlik qilgan katak indeksi (to'silganda).
  final int? blockIndex;

  /// To'sqinlik qilgan chiziq id'si (to'silganda).
  final int? blockerId;
}

class GameController extends ChangeNotifier {
  GameController({required this.seed, this.difficulty = Difficulty.medium, LevelGenerator? generator})
      : _generator = generator ?? LevelGenerator.forDifficulty(difficulty) {
    _newBoard();
  }

  static const int maxLives = 3;

  final int seed;
  final Difficulty difficulty;
  final LevelGenerator _generator;

  late Board board;
  late int totalLines;
  int removedCount = 0;
  int lives = maxLives;
  GameStatus status = GameStatus.playing;
  int? hintId;

  double get progress => totalLines == 0 ? 1 : removedCount / totalLines;

  void _newBoard() {
    board = _generator.generate(seed);
    totalLines = board.lines.length;
    removedCount = 0;
    lives = maxLives;
    status = GameStatus.playing;
    hintId = null;
  }

  void restart() {
    _newBoard();
    notifyListeners();
  }

  TapResult? tap(int id) {
    if (status != GameStatus.playing) return null;
    final line = board.lines[id];
    if (line == null) return null;

    final ray = board.exitRay(line);
    final blockIndex = board.firstBlockIndex(line);
    if (blockIndex == null) {
      board.remove(id);
      removedCount++;
      if (hintId == id) hintId = null;
      if (board.isEmpty) status = GameStatus.won;
      notifyListeners();
      return TapResult.removed(line, ray);
    }

    lives--;
    if (lives <= 0) {
      lives = 0;
      status = GameStatus.lost;
    }
    notifyListeners();
    return TapResult.blocked(
        line, ray, blockIndex, board.occupantOf(ray[blockIndex]));
  }

  /// Olib tashlash mumkin bo'lgan chiziqni yoritadi. Muvaffaqiyatda true.
  bool showHint() {
    if (status != GameStatus.playing) return false;
    final line = board.findRemovable();
    if (line == null) return false;
    hintId = line.id;
    notifyListeners();
    return true;
  }
}
