import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color accentYellow = Color(0xFFFFEB3B);
  static const Color darkText = Color(0xFF212121);
  static const Color mediumGray = Color(0xFFBDBDBD);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryOrange),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryOrange),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryOrange),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryOrange,
      secondary: accentYellow,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: accentYellow),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryOrange, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryOrange),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryOrange;
        }
        return Colors.grey;
      }),
    ),
  );
}
