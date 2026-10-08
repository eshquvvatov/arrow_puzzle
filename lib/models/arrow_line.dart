import 'dart:math';

/// To'rtta ortogonal yo'nalish.
enum Direction {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  const Direction(this.dx, this.dy);

  final int dx;
  final int dy;

  /// Qo'shni ikki katak orasidagi yo'nalish (a → b).
  static Direction between(Point<int> a, Point<int> b) {
    if (b.x > a.x) return Direction.right;
    if (b.x < a.x) return Direction.left;
    if (b.y > a.y) return Direction.down;
    return Direction.up;
  }
}

/// Bitta strelkali chiziq ("ilon").
///
/// [cells] — dumidan boshigacha tartiblangan, o'z-o'zini kesmaydigan
/// ortogonal yo'l. Strelka boshi — oxirgi katak.
class ArrowLine {
  ArrowLine({required this.id, required this.cells})
      : assert(cells.length >= 2, 'Chiziq kamida 2 katakdan iborat');

  final int id;
  final List<Point<int>> cells;

  Point<int> get head => cells.last;

  /// Strelka yo'nalishi — oxirgi segment yo'nalishi.
  Direction get direction =>
      Direction.between(cells[cells.length - 2], cells.last);
}
