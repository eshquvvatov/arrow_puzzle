import 'package:arrow_puzzle/generator/level_generator.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

/// Greedy solver: har qadamda istalgan olib tashlanadigan chiziqni oladi.
bool greedySolve(Board board) {
  while (!board.isEmpty) {
    final line = board.findRemovable();
    if (line == null) return false;
    board.remove(line.id);
  }
  return true;
}

void main() {
  for (final d in Difficulty.values) {
    group('Difficulty.${d.name}', () {
      test("25 seed: o'lcham, yechiladi, chiziqlar > 3", () {
        final gen = LevelGenerator.forDifficulty(d);
        for (var seed = 100; seed <= 124; seed++) {
          final board = gen.generate(seed);
          expect(board.width, d.width,
              reason: 'seed=$seed: width mos emas');
          expect(board.height, d.height,
              reason: 'seed=$seed: height mos emas');
          expect(board.lines.length, greaterThan(3),
              reason: 'seed=$seed: chiziqlar juda kam');
          expect(greedySolve(board), isTrue,
              reason: 'seed=$seed yechilmadi');
        }
      });

      test('determinizm: bir xil seed bir xil level beradi', () {
        final gen = LevelGenerator.forDifficulty(d);
        final a = gen.generate(200);
        final b = gen.generate(200);
        expect(a.lines.length, b.lines.length);
        for (final id in a.lines.keys) {
          expect(a.lines[id]!.cells, b.lines[id]!.cells);
        }
      });
    });
  }

  test('seedFor uch qiyinlik uchun uch xil qiymat beradi', () {
    final date = DateTime(2026, 7, 2);
    final seeds = {
      for (final d in Difficulty.values) LevelGenerator.seedFor(date, d),
    };
    expect(seeds.length, 3);
  });

  test("Hard: to'ldirilganlik > 0.4", () {
    final d = Difficulty.hard;
    final gen = LevelGenerator.forDifficulty(d);
    for (var seed = 100; seed <= 124; seed++) {
      final board = gen.generate(seed);
      final covered = board.lines.values
          .fold<int>(0, (sum, line) => sum + line.cells.length);
      expect(covered / (d.width * d.height), greaterThan(0.4),
          reason: "seed=$seed: to'ldirilganlik < 0.4");
    }
  });
}
