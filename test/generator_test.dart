import 'package:arrow_puzzle/generator/level_generator.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

/// Greedy solver: har qadamda istalgan olib tashlanadigan chiziqni oladi.
/// Doska to'liq tozalansa — level yechiladigan.
bool greedySolve(Board board) {
  while (!board.isEmpty) {
    final line = board.findRemovable();
    if (line == null) return false;
    board.remove(line.id);
  }
  return true;
}

void main() {
  test("har bir seed uchun level yechiladigan bo'ladi", () {
    final gen = LevelGenerator();
    for (var seed = 1; seed <= 50; seed++) {
      final board = gen.generate(seed);
      expect(board.lines.length, greaterThan(5),
          reason: 'seed=$seed: chiziqlar juda kam');
      expect(greedySolve(board), isTrue, reason: 'seed=$seed yechilmadi');
    }
  });

  test('bir xil seed bir xil levelni beradi (determinizm)', () {
    final gen = LevelGenerator();
    final a = gen.generate(20260702);
    final b = gen.generate(20260702);
    expect(a.lines.length, b.lines.length);
    for (final id in a.lines.keys) {
      expect(a.lines[id]!.cells, b.lines[id]!.cells);
    }
  });

  test('kunlik seed sanadan deterministik hisoblanadi', () {
    expect(LevelGenerator.seedForDate(DateTime(2026, 7, 2)), 20260702);
  });

  test("doska yetarlicha to'ldiriladi", () {
    final gen = LevelGenerator();
    final board = gen.generate(42);
    final covered = board.lines.values
        .fold<int>(0, (sum, line) => sum + line.cells.length);
    expect(covered / (gen.width * gen.height), greaterThan(0.4));
  });
}
