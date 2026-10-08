import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../game/game_controller.dart';
import '../../models/arrow_line.dart';
import '../../services/sound_service.dart';
import '../../theme/palettes.dart';
import 'board_painter.dart';

/// Doska: chizish, tap aniqlash va animatsiyalar.
class BoardView extends StatefulWidget {
  const BoardView({super.key, required this.controller, this.onBoardCleared});

  final GameController controller;

  /// Oxirgi chiziq chiqib bo'lgach (animatsiya tugagach) chaqiriladi.
  final VoidCallback? onBoardCleared;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _AnimatedLine {
  _AnimatedLine(this.line, this.anim, this.maxOffsetCells,
      {this.bounce = false, this.blockerId});

  final ArrowLine line;
  final AnimationController anim;
  final double maxOffsetCells;

  /// true — to'qnashuv: oldinga borib qaytadi; false — chiqib ketadi.
  final bool bounce;
  final int? blockerId;

  double get offsetCells {
    final t = anim.value;
    if (bounce) return maxOffsetCells * math.sin(math.pi * t);
    return maxOffsetCells * Curves.easeIn.transform(t);
  }
}

class _BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  final List<_AnimatedLine> _moving = [];
  int? _pressedId;
  late final AnimationController _hintPulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onGameChanged);
    _syncHintPulse();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onGameChanged);
    _hintPulse.dispose();
    for (final m in _moving) {
      m.anim.dispose();
    }
    _moving.clear();
    super.dispose();
  }

  void _onGameChanged() {
    if (!mounted) return;
    if (_pressedId != null &&
        !widget.controller.board.lines.containsKey(_pressedId)) {
      _pressedId = null;
    }
    _syncHintPulse();
    setState(() {});
  }

  void _syncHintPulse() {
    if (widget.controller.hintId != null) {
      if (!_hintPulse.isAnimating) _hintPulse.repeat(reverse: true);
    } else {
      _hintPulse.stop();
    }
  }

  void _activate(int id) {
    final result = widget.controller.tap(id);
    if (result == null) return;

    if (result.removed) {
      soundService.whoosh();
      HapticFeedback.lightImpact();
      final dist = result.ray.length + result.line.cells.length + 1.5;
      final anim = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (120 + dist * 26).round().clamp(250, 850)),
      );
      final moving = _AnimatedLine(result.line, anim, dist);
      setState(() => _moving.add(moving));
      anim.addListener(_repaint);
      anim.forward().whenComplete(() {
        anim.dispose();
        if (!mounted) return;
        setState(() => _moving.remove(moving));
        if (widget.controller.status == GameStatus.won && _moving.isEmpty) {
          widget.onBoardCleared?.call();
        }
      });
    } else {
      soundService.thud();
      HapticFeedback.mediumImpact();
      final anim = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 420));
      final moving = _AnimatedLine(
        result.line,
        anim,
        result.blockIndex! + 0.45,
        bounce: true,
        blockerId: result.blockerId,
      );
      setState(() => _moving.add(moving));
      anim.addListener(_repaint);
      anim.forward().whenComplete(() {
        anim.dispose();
        if (mounted) setState(() => _moving.remove(moving));
      });
    }
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  int? _hitTest(Offset pos, BoardGeometry geo) {
    int? best;
    var bestDist = geo.cellSize * 0.65;
    for (final line in widget.controller.board.lines.values) {
      for (var i = 0; i < line.cells.length - 1; i++) {
        final a = geo.center(line.cells[i]);
        final b = geo.center(line.cells[i + 1]);
        final dist = _distToSegment(pos, a, b);
        if (dist < bestDist) {
          bestDist = dist;
          best = line.id;
        }
      }
    }
    return best;
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    final proj = a + Offset(ab.dx * t, ab.dy * t);
    return (p - proj).distance;
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.controller.board;
    final palette = themeController.palette;
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final geo = BoardGeometry(size, board.width, board.height);
      final movingIds = {for (final m in _moving) m.line.id};
      final statics = [
        for (final line in board.lines.values)
          if (!movingIds.contains(line.id)) line,
      ];
      final blockerIds = {
        for (final m in _moving)
          if (m.bounce && m.blockerId != null) m.blockerId!,
      };
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) {
          final id = _hitTest(d.localPosition, geo);
          if (id != null && !_moving.any((m) => m.line.id == id)) {
            soundService.tap();
            setState(() => _pressedId = id);
          }
        },
        onTapCancel: () => setState(() => _pressedId = null),
        onTapUp: (d) {
          final id = _pressedId;
          setState(() => _pressedId = null);
          if (id == null) return;
          _activate(id);
        },
        child: AnimatedBuilder(
          animation: _hintPulse,
          builder: (context, _) => CustomPaint(
            size: size,
            painter: BoardPainter(
              cols: board.width,
              rows: board.height,
              staticLines: statics,
              movingLines: [
                for (final m in _moving)
                  MovingLine(line: m.line, offsetCells: m.offsetCells),
              ],
              hintId: widget.controller.hintId,
              hintPulse: Curves.easeInOut.transform(_hintPulse.value),
              blockerIds: blockerIds,
              palette: palette,
              pressedId: _pressedId,
            ),
          ),
        ),
      );
    });
  }
}
