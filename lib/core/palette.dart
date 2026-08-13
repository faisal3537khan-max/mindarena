import 'package:flutter/material.dart';

class ArenaPalette {
  static const voidBlack = Color(0xFF050510);
  static const deepNavy = Color(0xFF0B1024);
  static const panel = Color(0xCC12182F);
  static const cyan = Color(0xFF00F0FF);
  static const magenta = Color(0xFFFF2BD6);
  static const gold = Color(0xFFFFD166);
  static const lime = Color(0xFF7CFF6B);
  static const danger = Color(0xFFFF4D6D);
  static const electric = Color(0xFF7A5CFF);
  static const text = Color(0xFFF4F7FF);
  static const mute = Color(0xFF9AA6C8);

  static const optionColors = [
    Color(0xFFFF4D6D),
    Color(0xFF00B4FF),
    Color(0xFF7CFF6B),
    Color(0xFFFFD166),
  ];

  static const colorblindOptions = [
    Color(0xFF0072B2),
    Color(0xFFE69F00),
    Color(0xFF009E73),
    Color(0xFFCC79A7),
  ];

  static List<Color> pads(bool colorblind) => colorblind ? colorblindOptions : optionColors;

  static Color named(String n) => switch (n) {
        'magenta' => magenta,
        'gold' => gold,
        'lime' => lime,
        'electric' => electric,
        _ => cyan,
      };

  static LinearGradient arenaGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF09091A), Color(0xFF12061F), Color(0xFF050510)],
  );
}
