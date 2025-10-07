import 'package:flutter/material.dart';

class CyberTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.blueAccent,
      secondary: Colors.cyanAccent,
      background: Colors.white,
      surface: Colors.grey[200]!,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0A192F), // Azul oscuro
    scaffoldBackgroundColor: const Color(0xFF0A192F),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF64FFDA), // Cian brillante
      secondary: Color(0xFFFF4081), // Magenta
      background: Color(0xFF0A192F),
      surface: Color(0xFF112240),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: Color(0xFFCCD6F6), // Texto claro
      onSurface: Color(0xFFCCD6F6),
      error: Colors.redAccent,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFCCD6F6)),
      bodyMedium: TextStyle(color: Color(0xFF8892B0)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF112240),
      foregroundColor: Color(0xFFCCD6F6),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: const Color(0xFF64FFDA),
      ),
    ),
  );
}