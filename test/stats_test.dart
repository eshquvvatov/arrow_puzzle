import 'package:arrow_puzzle/services/stats.dart';
import 'package:flutter_test/flutter_test.dart';

int k(int y, int m, int d) => y * 10000 + m * 100 + d;

void main() {
  final today = DateTime(2026, 7, 2);

  group('dateFromKey', () {
    test('20260702 → DateTime(2026,7,2)', () {
      expect(dateFromKey(20260702), DateTime(2026, 7, 2));
    });
  });

  group('currentStreak', () {
    test("bo'sh set → 0", () {
      expect(currentStreak({}, today), 0);
    });

    test('faqat bugun → 1', () {
      expect(currentStreak({k(2026, 7, 2)}, today), 1);
    });

    test('bugun + kecha → 2', () {
      expect(currentStreak({k(2026, 7, 1), k(2026, 7, 2)}, today), 2);
    });

    test('bugun yechilmagan, kecha yechilgan → currentStreak 1', () {
      expect(currentStreak({k(2026, 7, 1)}, today), 1);
    });

    test("bugun yechilmagan, kecha ham yo'q → 0", () {
      expect(currentStreak({k(2026, 6, 30)}, today), 0);
    });

    test('oy chegarasi: 30-iyun, 1-iyul, 2-iyul → currentStreak 3', () {
      final days = {k(2026, 6, 30), k(2026, 7, 1), k(2026, 7, 2)};
      expect(currentStreak(days, today), 3);
    });
  });

  group('longestStreak', () {
    test("bo'sh set → 0", () {
      expect(longestStreak({}), 0);
    });

    test('uzilishli tarix: longestStreak 3', () {
      final days = {
        k(2026, 6, 1),
        k(2026, 6, 2),
        k(2026, 6, 3),
        k(2026, 6, 10),
        k(2026, 6, 11),
      };
      expect(longestStreak(days), 3);
    });
  });
}
