import '../generator/level_generator.dart';
import '../services/dates.dart';
import '../services/storage.dart';

/// O'ynaladigan boshqotirmaga havola — rejimlar (kunlik/level) farqini
/// bir joyga yig'adi.
abstract class PuzzleRef {
  int get seed;
  LevelGenerator get generator;
  String get title;
  bool get isCompleted;
  Future<void> markCompleted();

  /// Keyingi boshqotirma (level rejimida n+1), bo'lmasa null.
  PuzzleRef? get next;
}

class DailyPuzzle implements PuzzleRef {
  DailyPuzzle(this.date, this.difficulty);

  final DateTime date;
  final Difficulty difficulty;

  @override
  int get seed => LevelGenerator.seedFor(date, difficulty);

  @override
  LevelGenerator get generator => LevelGenerator.forDifficulty(difficulty);

  @override
  String get title => formatDateUz(date);

  @override
  bool get isCompleted => Storage.isCompletedFor(date, difficulty);

  @override
  Future<void> markCompleted() => Storage.markCompletedFor(date, difficulty);

  @override
  PuzzleRef? get next => null;
}

class LevelPuzzle implements PuzzleRef {
  LevelPuzzle(this.n);

  final int n;

  @override
  int get seed => LevelGenerator.seedForLevel(n);

  @override
  LevelGenerator get generator => LevelGenerator.forLevel(n);

  @override
  String get title => 'Level $n';

  @override
  bool get isCompleted => Storage.completedLevels.contains(n);

  @override
  Future<void> markCompleted() => Storage.markLevelCompleted(n);

  @override
  PuzzleRef? get next => LevelPuzzle(n + 1);
}
