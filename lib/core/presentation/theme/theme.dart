import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF0D47A1); // Deep Blue
  static const Color secondaryLight = Color(0xFF1976D2); // Blue
  static const Color accentLight = Color(0xFF2196F3); // Light Blue
  static const Color backgroundLight = Color(0xFFF5F5F5); // Almost White
  static const Color surfaceLight = Colors.white;
  static const Color errorLight = Color(0xFFB00020); // Standard Error Red
  static const Color textPrimaryLight = Color(0xFF212121); // Near Black
  static const Color textSecondaryLight = Color(0xFF757575); // Medium Grey

  // Dark Theme Colors - Grok-style pure dark
  static const Color primaryDark = Color(0xFF1A1A1A); // Pure dark
  static const Color secondaryDark = Color(0xFF2D2D2D); // Dark grey
  static const Color accentDark = Color(0xFF3D3D3D); // Accent grey
  static const Color backgroundDark = Color(0xFF000000); // Pure black background
  static const Color surfaceDark = Color(0xFF0D0D0D); // Near black surface
  static const Color cardSurfaceDark = Color(0xFF1A1A1A); // Dark grey for cards
  static const Color errorDark = Color(0xFFFF4444); // Bright red for dark mode
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondaryDark = Color(0xFF9E9E9E); // Medium grey

  // Shared colors
  static const Color success = Color(0xFF4CAF50); // Green for success states
  static const Color warning = Color(0xFFFFC107); // Amber for warnings
  static const Color info = Color(0xFF03A9F4); // Light Blue for info
  
  // Get the light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        background: backgroundLight,
        surface: surfaceLight,
        error: errorLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryLight,
        onSurface: textPrimaryLight,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryLight),
        displayMedium: TextStyle(color: textPrimaryLight),
        displaySmall: TextStyle(color: textPrimaryLight),
        headlineMedium: TextStyle(color: textPrimaryLight),
        headlineSmall: TextStyle(color: textPrimaryLight),
        titleLarge: TextStyle(color: textPrimaryLight),
        titleMedium: TextStyle(color: textPrimaryLight),
        titleSmall: TextStyle(color: textPrimaryLight),
        bodyLarge: TextStyle(color: textPrimaryLight),
        bodyMedium: TextStyle(color: textPrimaryLight),
        bodySmall: TextStyle(color: textSecondaryLight),
        labelLarge: TextStyle(color: textPrimaryLight),
      ),
    );
  }

  // Get the dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        background: backgroundDark,
        surface: surfaceDark,
        surfaceVariant: cardSurfaceDark,
        error: errorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textPrimaryDark,
        onSurface: textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardSurfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D0D0D), // Pure dark header
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardSurfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2D2D2D), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryDark),
        displayMedium: TextStyle(color: textPrimaryDark),
        displaySmall: TextStyle(color: textPrimaryDark),
        headlineMedium: TextStyle(color: textPrimaryDark),
        headlineSmall: TextStyle(color: textPrimaryDark),
        titleLarge: TextStyle(color: textPrimaryDark),
        titleMedium: TextStyle(color: textPrimaryDark),
        titleSmall: TextStyle(color: textPrimaryDark),
        bodyLarge: TextStyle(color: textPrimaryDark),
        bodyMedium: TextStyle(color: textPrimaryDark),
        bodySmall: TextStyle(color: textSecondaryDark),
        labelLarge: TextStyle(color: textPrimaryDark),
      ),
    );
  }
}
