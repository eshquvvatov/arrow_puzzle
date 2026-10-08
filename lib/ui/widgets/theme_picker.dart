import 'package:flutter/material.dart';

import '../../services/sound_service.dart';
import '../../theme/palettes.dart';

/// Rang mavzusini tanlash pastki oynasi.
void showThemePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ListenableBuilder(
      listenable: themeController,
      builder: (ctx, _) {
        final p = themeController.palette;
        return Container(
          decoration: BoxDecoration(
            color: p.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mavzu',
                style: TextStyle(
                  color: p.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < palettes.length; i++)
                    _PaletteSwatch(
                      index: i,
                      selected: i == themeController.value,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: soundService,
                builder: (context, _) => Row(
                  children: [
                    Icon(
                      soundService.enabled
                          ? Icons.volume_up
                          : Icons.volume_off,
                      color: p.ink,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ovoz',
                      style: TextStyle(
                        color: p.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: soundService.enabled,
                      activeThumbColor: p.accent,
                      onChanged: (v) => soundService.setEnabled(v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.index, required this.selected});

  final int index;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final pal = palettes[index];
    return GestureDetector(
      onTap: () => themeController.select(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: pal.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? pal.accent
                    : pal.line.withValues(alpha: 0.3),
                width: selected ? 3 : 1.5,
              ),
            ),
            child: Icon(Icons.turn_right, color: pal.line),
          ),
          const SizedBox(height: 6),
          Text(
            pal.name,
            style: TextStyle(
              color: themeController.palette.ink,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
