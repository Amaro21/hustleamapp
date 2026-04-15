import 'package:flutter/material.dart';

class AppTheme {
  static const Color studioWhite = Color(0xFFFBFBFC);
  static const Color hustleamGreen = Color(0xFF00B761);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: studioWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
        fontSize: 15,
      ),
    ),
  );
}
