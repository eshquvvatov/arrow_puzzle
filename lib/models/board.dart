import 'dart:math';

import 'arrow_line.dart';

/// O'yin doskasi: to'r ustidagi chiziqlar to'plami.
class Board {
  Board({
    required this.width,
    required this.height,
    required List<ArrowLine> lines,
  }) : lines = {for (final l in lines) l.id: l} {
    for (final line in lines) {
      for (final c in line.cells) {
        _occupancy[c] = line.id;
      }
    }
  }

  final int width;
  final int height;
  final Map<int, ArrowLine> lines;
  final Map<Point<int>, int> _occupancy = {};

  bool get isEmpty => lines.isEmpty;

  bool inBounds(Point<int> c) =>
      c.x >= 0 && c.x < width && c.y >= 0 && c.y < height;

  /// Katakni egallagan chiziq id'si (bo'sh bo'lsa null).
  int? occupantOf(Point<int> c) => _occupancy[c];

  /// Strelka uchidan doska chetigacha bo'lgan to'g'ri nur kataklari.
  List<Point<int>> exitRay(ArrowLine line) {
    final d = line.direction;
    final ray = <Point<int>>[];
    var c = Point(line.head.x + d.dx, line.head.y + d.dy);
    while (inBounds(c)) {
      ray.add(c);
      c = Point(c.x + d.dx, c.y + d.dy);
    }
    return ray;
  }

  /// Chiqish nuridagi birinchi to'siq katak indeksi; yo'l ochiq bo'lsa null.
  int? firstBlockIndex(ArrowLine line) {
    final ray = exitRay(line);
    for (var i = 0; i < ray.length; i++) {
      final occ = _occupancy[ray[i]];
      if (occ != null && occ != line.id) return i;
    }
    return null;
  }

  bool isRemovable(ArrowLine line) => firstBlockIndex(line) == null;

  void remove(int id) {
    final line = lines.remove(id);
    if (line == null) return;
    for (final c in line.cells) {
      if (_occupancy[c] == id) _occupancy.remove(c);
    }
  }

  /// Hozir olib tashlash mumkin bo'lgan biror chiziq (hint va solver uchun).
  ArrowLine? findRemovable() {
    for (final line in lines.values) {
      if (isRemovable(line)) return line;
    }
    return null;
  }
}
