import 'package:arrow_puzzle/generator/level_generator.dart';
import 'package:arrow_puzzle/services/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  test('default difficulty == medium', () {
    expect(Storage.difficulty, Difficulty.medium);
  });

  test('setDifficulty(hard) → hard', () async {
    await Storage.setDifficulty(Difficulty.hard);
    expect(Storage.difficulty, Difficulty.hard);
  });

  test("markCompletedFor faqat easy set'iga tushadi", () async {
    final date = DateTime(2026, 7, 2);
    await Storage.markCompletedFor(date, Difficulty.easy);
    expect(Storage.isCompletedFor(date, Difficulty.easy), isTrue);
    expect(Storage.isCompletedFor(date, Difficulty.medium), isFalse);
  });

  test("allCompletedDays uch qiyinlik union'i", () async {
    final jul1 = DateTime(2026, 7, 1);
    final jul2 = DateTime(2026, 7, 2);
    await Storage.markCompletedFor(jul1, Difficulty.easy);
    await Storage.markCompletedFor(jul2, Difficulty.hard);
    final all = Storage.allCompletedDays;
    expect(all.contains(Storage.dateKey(jul1)), isTrue);
    expect(all.contains(Storage.dateKey(jul2)), isTrue);
  });

  test('default soundOn == true', () {
    expect(Storage.soundOn, isTrue);
  });

  test('setSoundOn(false) → false', () async {
    await Storage.setSoundOn(false);
    expect(Storage.soundOn, isFalse);
  });
}
