import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';

ThemeData buildArenaTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: ArenaPalette.voidBlack,
    colorScheme: const ColorScheme.dark(
      primary: ArenaPalette.cyan,
      secondary: ArenaPalette.magenta,
      surface: ArenaPalette.deepNavy,
      error: ArenaPalette.danger,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).apply(
      bodyColor: ArenaPalette.text,
      displayColor: ArenaPalette.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
