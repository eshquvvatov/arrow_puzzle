import 'dart:math';

import '../models/arrow_line.dart';
import '../models/board.dart';

/// O'yin qiyinlik darajalari — generator parametrlarini belgilaydi.
enum Difficulty {
  easy(width: 8, height: 10, fillTarget: 0.45, minLen: 3, maxLen: 8,
      maxFailures: 800, label: 'Oson'),
  medium(width: 11, height: 14, fillTarget: 0.55, minLen: 3, maxLen: 12,
      maxFailures: 800, label: "O'rta"),
  hard(width: 13, height: 17, fillTarget: 0.62, minLen: 4, maxLen: 14,
      maxFailures: 1500, label: 'Qiyin');

  const Difficulty({
    required this.width,
    required this.height,
    required this.fillTarget,
    required this.minLen,
    required this.maxLen,
    required this.maxFailures,
    required this.label,
  });

  final int width;
  final int height;
  final double fillTarget;
  final int minLen;
  final int maxLen;
  final int maxFailures;
  final String label;
}

/// Yechilishi kafolatlangan level generator (teskari qurish usuli).
///
/// Chiziqlar birma-bir joylashtiriladi va har bir yangi chiziqning chiqish
/// nuri avval joylashtirilganlardan (va o'z tanasidan) xoli bo'lishi talab
/// qilinadi. Shunda joylashtirishning teskari tartibi — yechim; olib tashlash
/// kataklarni faqat bo'shatgani uchun istalgan greedy tartib ham ishlaydi.
class LevelGenerator {
  LevelGenerator({
    this.width = 11,
    this.height = 14,
    this.fillTarget = 0.55,
    this.minLen = 3,
    this.maxLen = 12,
    this.maxFailures = 800,
  });

  factory LevelGenerator.forDifficulty(Difficulty d) => LevelGenerator(
        width: d.width,
        height: d.height,
        fillTarget: d.fillTarget,
        minLen: d.minLen,
        maxLen: d.maxLen,
        maxFailures: d.maxFailures,
      );

  final int width;
  final int height;

  /// Kataklarning qancha qismi chiziqlar bilan to'ldirilishi kerak.
  final double fillTarget;
  final int minLen;
  final int maxLen;
  final int maxFailures;

  static int seedForDate(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  static int seedFor(DateTime date, Difficulty d) =>
      seedForDate(date) * 10 + d.index;

  /// Level rejimi seed'lari — kunlik (dateKey*10+diff) va test seed'lari
  /// bilan kesishmasligi uchun alohida diapazon.
  static int seedForLevel(int n) => 1000000 + n;

  /// Level raqamiga qarab silliq o'sadigan qiyinlik: 1-level juda oson,
  /// ~40-levelda maksimal, keyin parametrlar qotadi (seed farqi baribir
  /// yangi boshqotirma beradi).
  factory LevelGenerator.forLevel(int n) {
    final t = ((n - 1) / 39).clamp(0.0, 1.0);
    final fill = 0.40 + 0.38 * t;
    return LevelGenerator(
      width: 7 + (11 * t).round(),    // 7 → 18
      height: 9 + (15 * t).round(),   // 9 → 24
      fillTarget: fill,               // 0.40 → 0.78
      minLen: t > 0.5 ? 2 : 3,         // yuqori levellarda qisqa chiziqqa ruxsat
      maxLen: 6 + (8 * t).round(),    // 6 → 14
      maxFailures: 800 + (39200 * t).round(),  // 800 → 40000
    );
  }

  Board generateDaily(DateTime date) => generate(seedForDate(date));

  Board generate(int seed) {
    final rng = Random(seed);
    final occupied = <Point<int>>{};
    final placed = <ArrowLine>[];
    final totalCells = width * height;
    var failures = 0;
    while (occupied.length < totalCells * fillTarget && failures < maxFailures) {
      final line = _tryPlace(rng, occupied, placed.length);
      if (line == null) {
        failures++;
        continue;
      }
      placed.add(line);
      occupied.addAll(line.cells);
    }
    return Board(width: width, height: height, lines: placed);
  }

  ArrowLine? _tryPlace(Random rng, Set<Point<int>> occupied, int id) {
    final start = Point(rng.nextInt(width), rng.nextInt(height));
    if (occupied.contains(start)) return null;

    // Tasodifiy o'z-o'zini kesmaydigan yo'l (dumdan boshga qarab).
    final targetLen = minLen + rng.nextInt(maxLen - minLen + 1);
    final path = <Point<int>>[start];
    final pathSet = <Point<int>>{start};
    while (path.length < targetLen) {
      final dirs = List.of(Direction.values)..shuffle(rng);
      Point<int>? next;
      for (final d in dirs) {
        final c = Point(path.last.x + d.dx, path.last.y + d.dy);
        if (_inBounds(c) && !occupied.contains(c) && !pathSet.contains(c)) {
          next = c;
          break;
        }
      }
      if (next == null) break;
      path.add(next);
      pathSet.add(next);
    }
    if (path.length < minLen) return null;

    // Prefix-trim: nur band bo'lsa oxirgi katak olib tashlanadi (head va
    // yo'nalish o'zgaradi), minLen'gacha qayta tekshiriladi. Har prefiks
    // ikkala orientatsiyada sinaladi — asl va teskari (bosh boshqa uchida,
    // yo'nalish boshqa). Deterministik — Random ishlatmaydi.
    while (path.length >= minLen) {
      for (final cells in [List.of(path), List.of(path.reversed)]) {
        final line = ArrowLine(id: id, cells: cells);
        if (_rayIsClear(line, occupied, pathSet)) return line;
      }
      pathSet.remove(path.removeLast());
    }
    return null;
  }

  /// Chiqish nurining yo'li bo'sh ekanligini tekshiradi: head'dan yo'nalish
  /// bo'ylab chekkagacha birorta to'siq (occupied yoki pathSet) yo'q bo'lishi shart.
  bool _rayIsClear(
      ArrowLine line, Set<Point<int>> occupied, Set<Point<int>> pathSet) {
    final d = line.direction;
    var c = Point(line.head.x + d.dx, line.head.y + d.dy);
    while (_inBounds(c)) {
      if (occupied.contains(c) || pathSet.contains(c)) return false;
      c = Point(c.x + d.dx, c.y + d.dy);
    }
    return true;
  }

  bool _inBounds(Point<int> c) =>
      c.x >= 0 && c.x < width && c.y >= 0 && c.y < height;
}
