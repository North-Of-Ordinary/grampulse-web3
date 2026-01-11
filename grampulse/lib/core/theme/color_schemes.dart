import 'package:flutter/material.dart';

// Color schemes for light and dark themes
// Light mode: Clean whites and soft greys
final lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: const Color(0xFF2E2E2E),
  onPrimary: Colors.white,
  primaryContainer: const Color(0xFFE8E8E8),
  onPrimaryContainer: const Color(0xFF1A1A1A),
  secondary: const Color(0xFF4CAF50),
  onSecondary: Colors.white,
  secondaryContainer: const Color(0xFFE8F5E9),
  onSecondaryContainer: const Color(0xFF1B5E20),
  tertiary: const Color(0xFFFF6D00),
  onTertiary: Colors.white,
  tertiaryContainer: const Color(0xFFFFE0CC),
  onTertiaryContainer: const Color(0xFF4D2200),
  error: const Color(0xFFD32F2F),
  onError: Colors.white,
  errorContainer: const Color(0xFFFFEBEE),
  onErrorContainer: const Color(0xFFB71C1C),
  background: const Color(0xFFFAFAFA),
  onBackground: const Color(0xFF1A1A1A),
  surface: Colors.white,
  onSurface: const Color(0xFF1A1A1A),
  surfaceVariant: const Color(0xFFF5F5F5),
  onSurfaceVariant: const Color(0xFF616161),
  outline: const Color(0xFFBDBDBD),
);

// Refined dark color scheme with layered surfaces for visual hierarchy
// Grok-inspired: Deep blacks, soft greys, high-contrast text
final darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  // Primary - Neutral grey for clean dark theme
  primary: const Color(0xFFCCCCCC),
  onPrimary: const Color(0xFF0A0A0A),
  primaryContainer: const Color(0xFF333333),
  onPrimaryContainer: const Color(0xFFE8E8E8),
  // Secondary - Muted green
  secondary: const Color(0xFF5FBF6A),
  onSecondary: const Color(0xFF002105),
  secondaryContainer: const Color(0xFF1E3A1F),
  onSecondaryContainer: const Color(0xFFA8E5B0),
  // Tertiary - Soft amber accent
  tertiary: const Color(0xFFFFB86C),
  onTertiary: const Color(0xFF331400),
  tertiaryContainer: const Color(0xFF5A3800),
  onTertiaryContainer: const Color(0xFFFFDDB8),
  // Error states
  error: const Color(0xFFFF5555),
  onError: const Color(0xFF3D0000),
  errorContainer: const Color(0xFF5C0A0A),
  onErrorContainer: const Color(0xFFFFDAD6),
  // Layered dark surfaces (Grok-style deep blacks)
  background: const Color(0xFF000000), // True black background
  onBackground: const Color(0xFFEEEEEE),
  surface: const Color(0xFF0A0A0A), // Near-black surface
  onSurface: const Color(0xFFEEEEEE),
  surfaceVariant: const Color(0xFF1A1A1A), // Card/panel surface
  onSurfaceVariant: const Color(0xFFCCCCCC),
  // Outline for borders and dividers
  outline: const Color(0xFF404040), // Subtle but visible borders
);

// Additional dark mode surface colors for different elevation levels
// Grok-inspired layered surfaces
class DarkSurfaces {
  static const Color level0 = Color(0xFF000000); // True black background
  static const Color level1 = Color(0xFF0A0A0A); // Base surface
  static const Color level2 = Color(0xFF141414); // Card/Panel surface
  static const Color level3 = Color(0xFF1E1E1E); // Elevated components
  static const Color level4 = Color(0xFF282828); // Dialogs, modals
  static const Color level5 = Color(0xFF333333); // Highest elevation
  
  // Border colors
  static const Color borderSubtle = Color(0xFF1F1F1F);
  static const Color borderMedium = Color(0xFF2F2F2F);
  static const Color borderStrong = Color(0xFF404040);
}

// Status colors
final statusColors = {
  'new': const Color(0xFF2196F3),
  'in_progress': const Color(0xFFFF9800),
  'resolved': const Color(0xFF4CAF50),
  'overdue': const Color(0xFFF44336),
  'verified': const Color(0xFF9C27B0),
};
