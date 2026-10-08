import 'dart:math';

import 'package:arrow_puzzle/game/game_controller.dart';
import 'package:arrow_puzzle/models/arrow_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("olib tashlanadigan chiziq bosilganda progress o'sadi", () {
    final controller = GameController(seed: 20260702);
    final removable = controller.board.findRemovable()!;
    final result = controller.tap(removable.id)!;
    expect(result.removed, isTrue);
    expect(controller.removedCount, 1);
    expect(controller.progress, greaterThan(0));
    expect(controller.lives, GameController.maxLives);
  });

  test("to'silgan chiziq bosilganda jon kamayadi", () {
    final controller = GameController(seed: 20260702);
    ArrowLine? blocked;
    for (final line in controller.board.lines.values) {
      if (!controller.board.isRemovable(line)) {
        blocked = line;
        break;
      }
    }
    expect(blocked, isNotNull, reason: "levelda to'silgan chiziq bo'lishi kerak");
    final result = controller.tap(blocked!.id)!;
    expect(result.removed, isFalse);
    expect(result.blockIndex, isNotNull);
    expect(result.blockerId, isNotNull);
    expect(controller.lives, GameController.maxLives - 1);
    // Chiziq doskada qoladi.
    expect(controller.board.lines.containsKey(blocked.id), isTrue);
  });

  test("3 marta xato — o'yin tugaydi, restart tiklaydi", () {
    final controller = GameController(seed: 20260702);
    for (var i = 0; i < GameController.maxLives; i++) {
      ArrowLine? blocked;
      for (final line in controller.board.lines.values) {
        if (!controller.board.isRemovable(line)) {
          blocked = line;
          break;
        }
      }
      controller.tap(blocked!.id);
    }
    expect(controller.status, GameStatus.lost);
    expect(controller.tap(controller.board.lines.keys.first), isNull);
    controller.restart();
    expect(controller.status, GameStatus.playing);
    expect(controller.lives, GameController.maxLives);
    expect(controller.progress, 0);
  });

  test("hammasi olib tashlansa g'alaba", () {
    final controller = GameController(seed: 7);
    while (controller.status == GameStatus.playing) {
      final line = controller.board.findRemovable()!;
      final result = controller.tap(line.id)!;
      expect(result.removed, isTrue);
    }
    expect(controller.status, GameStatus.won);
    expect(controller.progress, 1);
    expect(controller.board.isEmpty, isTrue);
  });

  test('hint olib tashlanadigan chiziqni beradi', () {
    final controller = GameController(seed: 20260702);
    expect(controller.showHint(), isTrue);
    final hinted = controller.board.lines[controller.hintId]!;
    expect(controller.board.isRemovable(hinted), isTrue);
    // Hint qilingan chiziq olib tashlanganda hint tozalanadi.
    controller.tap(hinted.id);
    expect(controller.hintId, isNull);
  });

  test("to'siq id'si nurdagi katakni egallagan chiziqqa tegishli", () {
    final controller = GameController(seed: 20260702);
    for (final line in controller.board.lines.values.toList()) {
      final idx = controller.board.firstBlockIndex(line);
      if (idx != null) {
        final ray = controller.board.exitRay(line);
        final Point<int> blockCell = ray[idx];
        expect(controller.board.occupantOf(blockCell), isNot(line.id));
        break;
      }
    }
  });
}
