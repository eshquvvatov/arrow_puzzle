import 'package:flutter/material.dart';

import '../services/storage.dart';

/// Bitta rang mavzusi.
class Palette {
  const Palette({
    required this.name,
    required this.background,
    required this.line,
    required this.accent,
    required this.life,
    required this.ink,
  });

  final String name;
  final Color background;

  /// Chiziqlar rangi.
  final Color line;

  /// Sarlavha, tugmalar va hint yoritish rangi.
  final Color accent;

  /// Jon tomchilari rangi.
  final Color life;

  /// Asosiy matn rangi.
  final Color ink;
}

const palettes = <Palette>[
  Palette(
    name: 'Klassik',
    background: Color(0xFFF1E9D6),
    line: Color(0xFF6B4A32),
    accent: Color(0xFFCB7B2B),
    life: Color(0xFF3E9BE9),
    ink: Color(0xFF4E3A29),
  ),
  Palette(
    name: 'Tun',
    background: Color(0xFF211F1C),
    line: Color(0xFFD8C9A8),
    accent: Color(0xFFE0A458),
    life: Color(0xFF5AA7E0),
    ink: Color(0xFFE8DFC9),
  ),
  Palette(
    name: 'Dengiz',
    background: Color(0xFFE3EEF0),
    line: Color(0xFF2F5D74),
    accent: Color(0xFFE76F51),
    life: Color(0xFF2A9D8F),
    ink: Color(0xFF23485B),
  ),
  Palette(
    name: "O'rmon",
    background: Color(0xFFEAF1E2),
    line: Color(0xFF41603C),
    accent: Color(0xFFC05746),
    life: Color(0xFF3E9BE9),
    ink: Color(0xFF33502F),
  ),
];

/// To'qnashuvda to'siq chiziqni yoritish rangi.
const dangerColor = Color(0xFFD9534F);

class ThemeController extends ValueNotifier<int> {
  ThemeController() : super(Storage.themeIndex);

  Palette get palette => palettes[value % palettes.length];

  void select(int i) {
    value = i;
    Storage.setThemeIndex(i);
  }
}

/// Ilova bo'ylab yagona mavzu boshqaruvchisi.
final themeController = ThemeController();
