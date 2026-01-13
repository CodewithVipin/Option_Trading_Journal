import 'package:flutter/material.dart';

class AppTheme {
  // ☕ LIGHT COFFEE THEME (LATTE STYLE)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: const Color(0xFFFFFBF6), // Milk white

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFE6DAD1), // Light latte
      foregroundColor: Color(0xFF3E2723), // Dark coffee text
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFF3E2723), // Coffee text
      ),
      titleMedium: TextStyle(
        color: Color(0xFF2B1B14), // Dark roast
        fontWeight: FontWeight.bold,
      ),
      bodySmall: TextStyle(
        color: Color(0xFF6F4E37), // Cappuccino brown
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6F4E37), // Coffee brown
      secondary: Color(0xFFB08968), // Caramel
      surface: Color(0xFFF4ECE6), // Cream surface
      surfaceContainerHighest: Color(0xFFEADFD7),
      onPrimary: Colors.white,
      onSurface: Color(0xFF3E2723),
    ),

    dividerColor: const Color(0xFFD7C6BC),
    hintColor: const Color(0xFF8D6E63),
  );

  // ☕ DARK COFFEE THEME (ESPRESSO STYLE)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF1A120D), // Espresso black

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3E2723), // Dark mocha
      foregroundColor: Color(0xFFFFF3E0), // Cream text
      elevation: 0,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Color(0xFFFFF3E0), // Cream
      ),
      titleMedium: TextStyle(
        color: Color(0xFFFFE0B2), // Latte cream
        fontWeight: FontWeight.bold,
      ),
      bodySmall: TextStyle(
        color: Color(0xFFD7CCC8), // Light coffee foam
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB08968), // Warm coffee
      secondary: Color(0xFF8D6E63), // Mocha
      surface: Color(0xFF2B1B14), // Coffee surface
      surfaceContainerHighest: Color(0xFF3E2723),
      onPrimary: Color(0xFF1A120D),
      onSurface: Color(0xFFFFF3E0),
    ),

    dividerColor: const Color(0xFF4E342E),
    hintColor: const Color(0xFFBCAAA4),
  );
}
