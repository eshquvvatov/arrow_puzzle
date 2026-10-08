import 'package:shared_preferences/shared_preferences.dart';

import '../generator/level_generator.dart';

/// shared_preferences ustidan yupqa qatlam. [init] ilova boshida chaqiriladi.
class Storage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static String _completedKey(Difficulty d) => 'completed_${d.name}';

  static Set<int> completedDaysFor(Difficulty d) =>
      (_prefs.getStringList(_completedKey(d)) ?? const []).map(int.parse).toSet();

  static Future<void> markCompletedFor(DateTime date, Difficulty d) {
    final days = completedDaysFor(d)..add(dateKey(date));
    return _prefs
        .setStringList(_completedKey(d), days.map((e) => '$e').toList())
        .then((_) {});
  }

  static bool isCompletedFor(DateTime date, Difficulty d) =>
      completedDaysFor(d).contains(dateKey(date));

  /// Istalgan qiyinlikda yechilgan kunlar (streak uchun).
  static Set<int> get allCompletedDays => {
        for (final d in Difficulty.values) ...completedDaysFor(d),
      };

  static Difficulty get difficulty =>
      Difficulty.values[_prefs.getInt('difficulty') ?? Difficulty.medium.index];

  static Future<void> setDifficulty(Difficulty d) =>
      _prefs.setInt('difficulty', d.index);

  static int get themeIndex => _prefs.getInt('theme') ?? 0;

  static Future<void> setThemeIndex(int i) => _prefs.setInt('theme', i);

  /// Har kuni yangilanadigan hintlar soni.
  static const int dailyHints = 3;

  static int hintsRemaining(DateTime today) =>
      _prefs.getInt('hints_${dateKey(today)}') ?? dailyHints;

  static Future<void> setHintsRemaining(DateTime today, int value) =>
      _prefs.setInt('hints_${dateKey(today)}', value);

  static bool get soundOn => _prefs.getBool('sound_on') ?? true;

  static Future<void> setSoundOn(bool v) => _prefs.setBool('sound_on', v);

  /// Yechilgan levellar to'plami (istalgan tartibda o'ynash mumkin).
  static Set<int> get completedLevels =>
      (_prefs.getStringList('levels_done') ?? const []).map(int.parse).toSet();

  static Future<void> markLevelCompleted(int n) {
    final done = completedLevels..add(n);
    return _prefs
        .setStringList('levels_done', done.map((e) => '$e').toList())
        .then((_) {});
  }

  /// Birinchi yechilmagan level — home kartasi va "davom etish" uchun.
  static int get nextLevel {
    final done = completedLevels;
    var n = 1;
    while (done.contains(n)) {
      n++;
    }
    return n;
  }
}
