// Sof stat funksiyalar — Flutter'ga bog'liq emas, test qilinadi.

// ignore_for_file: dangling_library_doc_comments
int _keyOf(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// Sana kalitidan DateTime qaytaradi (format: yyyymmdd).
DateTime dateFromKey(int key) =>
    DateTime(key ~/ 10000, (key % 10000) ~/ 100, key % 100);

/// Bugungi kundan orqaga ketma-ket yechilgan kunlar soni.
/// Bugun yechilmagan bo'lsa hisoblash kechadan boshlanadi.
int currentStreak(Set<int> days, DateTime today) {
  if (days.isEmpty) return 0;
  DateTime cursor =
      days.contains(_keyOf(today)) ? today : today.subtract(const Duration(days: 1));
  int count = 0;
  while (days.contains(_keyOf(cursor))) {
    count++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return count;
}

/// Tarixdagi eng uzun ketma-ket seriya.
int longestStreak(Set<int> days) {
  if (days.isEmpty) return 0;
  final sorted = days.map(dateFromKey).toList()..sort();
  int longest = 1;
  int current = 1;
  for (int i = 1; i < sorted.length; i++) {
    final diff = sorted[i].difference(sorted[i - 1]).inDays;
    if (diff == 1) {
      current++;
      if (current > longest) longest = current;
    } else if (diff > 1) {
      current = 1;
    }
    // diff == 0 bo'lsa (takror kalit) — hisoblashni o'zgartirmaymiz
  }
  return longest;
}
