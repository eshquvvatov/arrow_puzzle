import 'dart:math';

import 'package:arrow_puzzle/models/arrow_line.dart';
import 'package:arrow_puzzle/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 5x5 doska: gorizontal chiziq o'ngga qaraydi, vertikal chiziq uning
  // nurini to'sib turadi.
  Board makeBoard() => Board(
        width: 5,
        height: 5,
        lines: [
          ArrowLine(id: 0, cells: const [Point(0, 2), Point(1, 2)]),
          ArrowLine(id: 1, cells: const [Point(3, 4), Point(3, 3), Point(3, 2)]),
        ],
      );

  test('exitRay doska chetigacha boradi', () {
    final board = makeBoard();
    final ray = board.exitRay(board.lines[0]!);
    expect(ray, const [Point(2, 2), Point(3, 2), Point(4, 2)]);
  });

  test("to'silgan chiziq olib tashlanmaydi, to'siq indeksi to'g'ri", () {
    final board = makeBoard();
    expect(board.isRemovable(board.lines[0]!), isFalse);
    expect(board.firstBlockIndex(board.lines[0]!), 1); // (3,2) katak
    expect(board.isRemovable(board.lines[1]!), isTrue); // yuqoriga yo'l ochiq
  });

  test("to'siq olib tashlangach yo'l ochiladi", () {
    final board = makeBoard();
    board.remove(1);
    expect(board.isRemovable(board.lines[0]!), isTrue);
    expect(board.occupantOf(const Point(3, 2)), isNull);
    board.remove(0);
    expect(board.isEmpty, isTrue);
  });

  test('strelka yo\'nalishi oxirgi segmentdan olinadi', () {
    final line =
        ArrowLine(id: 0, cells: const [Point(0, 0), Point(1, 0), Point(1, 1)]);
    expect(line.direction, Direction.down);
    expect(line.head, const Point(1, 1));
  });
}
