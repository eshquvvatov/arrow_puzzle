import 'package:arrow_puzzle/game/puzzle_ref.dart';
import 'package:arrow_puzzle/generator/level_generator.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:arrow_puzzle/services/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Greedy solver: har qadamda olib tashlanadigan birinchi chiziqni oladi.
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
  // ────────────────────────────────────────────────
  // 1. Yechilish
  // ────────────────────────────────────────────────
  group('Yechilish', () {
    const levels = [1, 10, 50, 100, 150, 200, 500];

    for (final n in levels) {
      test('level $n greedy bilan yechiladi va chiziqlar > 2', () {
        final gen = LevelGenerator.forLevel(n);
        final seed = LevelGenerator.seedForLevel(n);
        final board = gen.generate(seed);
        expect(board.lines.length, greaterThan(2),
            reason: 'level $n: chiziqlar juda kam');
        expect(greedySolve(board), isTrue,
            reason: 'level $n greedy solver bilan yechilmadi');
      }, timeout: const Timeout(Duration(seconds: 60)));
    }
  });

  // ────────────────────────────────────────────────
  // 2. Determinizm
  // ────────────────────────────────────────────────
  group('Determinizm', () {
    test('level 42 ikki marta generatsiya — bir xil chiziqlar', () {
      final gen = LevelGenerator.forLevel(42);
      final seed = LevelGenerator.seedForLevel(42);
      final a = gen.generate(seed);
      final b = gen.generate(seed);
      expect(a.lines.length, equals(b.lines.length),
          reason: 'chiziqlar soni farq qildi');
      for (final id in a.lines.keys) {
        expect(a.lines[id]!.cells, equals(b.lines[id]!.cells),
            reason: 'id=$id: cells farq qildi');
      }
    });
  });

  // ────────────────────────────────────────────────
  // 3. Monotonlik
  // ────────────────────────────────────────────────
  group('Monotonlik', () {
    LevelGenerator g(int n) => LevelGenerator.forLevel(n);

    test("level 1 parametrlari: width=7, height=9", () {
      final gen = g(1);
      expect(gen.width, equals(7));
      expect(gen.height, equals(9));
    });

    test("parametrlar 1 <= 20 <= 40 bo'yicha kamaymaydi", () {
      final g1 = g(1);
      final g20 = g(20);
      final g40 = g(40);

      expect(g20.width, greaterThanOrEqualTo(g1.width),
          reason: 'width: 20 < 1');
      expect(g40.width, greaterThanOrEqualTo(g20.width),
          reason: 'width: 40 < 20');

      expect(g20.height, greaterThanOrEqualTo(g1.height),
          reason: 'height: 20 < 1');
      expect(g40.height, greaterThanOrEqualTo(g20.height),
          reason: 'height: 40 < 20');

      expect(g20.fillTarget, greaterThanOrEqualTo(g1.fillTarget),
          reason: 'fillTarget: 20 < 1');
      expect(g40.fillTarget, greaterThanOrEqualTo(g20.fillTarget),
          reason: 'fillTarget: 40 < 20');

      expect(g20.maxLen, greaterThanOrEqualTo(g1.maxLen),
          reason: 'maxLen: 20 < 1');
      expect(g40.maxLen, greaterThanOrEqualTo(g20.maxLen),
          reason: 'maxLen: 40 < 20');
    });

    test('level 40 va 300 parametrlari bir xil (egri chiziq qotgan)', () {
      final g40 = g(40);
      final g300 = g(300);
      expect(g300.width, equals(g40.width),
          reason: 'width farq qildi');
      expect(g300.height, equals(g40.height),
          reason: 'height farq qildi');
      expect(g300.fillTarget, equals(g40.fillTarget),
          reason: 'fillTarget farq qildi');
      expect(g300.maxLen, equals(g40.maxLen),
          reason: 'maxLen farq qildi');
    });

    test('level 40 qamrovi >= 0.63 (empirik: ~0.660, chegara = 0.660 - 0.03)',
        () {
      final gen = g(40);
      final seed = LevelGenerator.seedForLevel(40);
      final board = gen.generate(seed);
      final total = gen.width * gen.height;
      int filled = 0;
      for (final line in board.lines.values) {
        filled += line.cells.length;
      }
      final coverage = filled / total;
      expect(coverage, greaterThanOrEqualTo(0.63),
          reason: 'level 40 qamrovi $coverage < 0.63');
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  // ────────────────────────────────────────────────
  // 4. Seed ajratilganligi
  // ────────────────────────────────────────────────
  group("Seed ajratilganligi", () {
    test('seedForLevel(1) == 1000001', () {
      expect(LevelGenerator.seedForLevel(1), equals(1000001));
    });

    test("level seed'lari kunlik seed'lar bilan kesishmaydi", () {
      // seedForLevel(n) = 1000000 + n  →  kichik n uchun [1000001, 1999999]
      // Kunlik seed: seedFor(date, diff) = (year*10000 + month*100 + day)*10 + diff.index
      // 2026-07-02 medium: 20260702 * 10 + 1 = 202607021  >> 1999999
      final dailySeed = LevelGenerator.seedFor(
          DateTime(2026, 7, 2), Difficulty.medium);
      // Kunlik seed 1000000 diapazoni tashqarisida ekanligini tekshir
      expect(dailySeed, greaterThan(1999999),
          reason: 'kunlik seed level diapazoni bilan kesishdi');
      // Spot-check: bir nechta level seed kunlik seed'ga teng emasligini tekshir
      for (var n = 1; n <= 999999; n += 100000) {
        expect(LevelGenerator.seedForLevel(n), isNot(equals(dailySeed)),
            reason: "seedForLevel($n) kunlik seed bilan toqnashdi");
      }
    });
  });

  // ────────────────────────────────────────────────
  // 5. Progress storage
  // ────────────────────────────────────────────────
  group('Progress storage', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('default: completedLevels bo\'sh, nextLevel == 1', () {
      expect(Storage.completedLevels, isEmpty);
      expect(Storage.nextLevel, equals(1));
    });

    test('markLevelCompleted(1), (2) → {1, 2}, nextLevel == 3', () async {
      await Storage.markLevelCompleted(1);
      expect(Storage.completedLevels, equals({1}));
      expect(Storage.nextLevel, equals(2));
      await Storage.markLevelCompleted(2);
      expect(Storage.completedLevels, equals({1, 2}));
      expect(Storage.nextLevel, equals(3));
    });

    test("qayta o'ynash progressni buzmaydi: {1,2} da (1) → {1,2} qoladi",
        () async {
      await Storage.markLevelCompleted(1);
      await Storage.markLevelCompleted(2);
      await Storage.markLevelCompleted(1); // qayta o'ynash
      expect(Storage.completedLevels, equals({1, 2}));
      expect(Storage.nextLevel, equals(3));
    });

    test("sakrash: markLevelCompleted(5) to'plamga qo'shiladi, "
        "nextLevel birinchi bo'shliqni qaytaradi", () async {
      await Storage.markLevelCompleted(1);
      await Storage.markLevelCompleted(2);
      await Storage.markLevelCompleted(5); // sakrash — endi ruxsat
      expect(Storage.completedLevels, equals({1, 2, 5}));
      expect(Storage.nextLevel, equals(3),
          reason: "nextLevel birinchi yechilmagan level bo'lishi kerak");
    });
  });

  // ────────────────────────────────────────────────
  // 6. LevelPuzzle
  // ────────────────────────────────────────────────
  group('LevelPuzzle', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('LevelPuzzle(3).next — LevelPuzzle va n == 4', () {
      final next = LevelPuzzle(3).next;
      expect(next, isA<LevelPuzzle>());
      expect((next as LevelPuzzle).n, equals(4));
    });

    test("LevelPuzzle(1).title == 'Level 1'", () {
      expect(LevelPuzzle(1).title, equals('Level 1'));
    });

    test('progress 2: LevelPuzzle(2).isCompleted true, (3) false', () async {
      await Storage.markLevelCompleted(1);
      await Storage.markLevelCompleted(2);
      expect(LevelPuzzle(2).isCompleted, isTrue);
      expect(LevelPuzzle(3).isCompleted, isFalse);
    });
  });
}
