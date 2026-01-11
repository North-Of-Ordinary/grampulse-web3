import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/color_schemes.dart';
import 'package:grampulse/core/theme/text_theme.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: lightColorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: lightColorScheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outline.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: lightColorScheme.onPrimary,
          backgroundColor: lightColorScheme.primary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: lightColorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: lightColorScheme.primary,
        unselectedItemColor: lightColorScheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightColorScheme.tertiary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightColorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: lightColorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: textTheme.apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),
      scaffoldBackgroundColor: DarkSurfaces.level0, // True black background
      // AppBar with true black background
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: DarkSurfaces.level0, // True black
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      // Cards with visible borders and elevation
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: DarkSurfaces.level2,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: DarkSurfaces.borderSubtle,
            width: 1,
          ),
        ),
      ),
      // Visible dividers
      dividerTheme: DividerThemeData(
        color: DarkSurfaces.borderMedium,
        thickness: 1,
        space: 1,
      ),
      // List tiles with proper padding
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        iconColor: darkColorScheme.onSurfaceVariant,
        textColor: darkColorScheme.onSurface,
      ),
      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimary,
          backgroundColor: darkColorScheme.primary,
          minimumSize: const Size(0, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      // Outlined buttons with visible borders
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          side: BorderSide(color: darkColorScheme.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
        ),
      ),
      // Input fields with clear borders
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: DarkSurfaces.borderMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: DarkSurfaces.borderMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        filled: true,
        fillColor: DarkSurfaces.level2,
        hintStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
      ),
      // Bottom nav - true black
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DarkSurfaces.level0,
        selectedItemColor: Colors.white,
        unselectedItemColor: darkColorScheme.onSurfaceVariant,
      ),
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkColorScheme.tertiary,
        foregroundColor: darkColorScheme.onTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      // Snackbars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkSurfaces.level4,
        contentTextStyle: TextStyle(color: darkColorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: DarkSurfaces.level3,
        selectedColor: darkColorScheme.primaryContainer,
        labelStyle: TextStyle(color: darkColorScheme.onSurface),
        side: BorderSide(color: DarkSurfaces.borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: DarkSurfaces.level4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: DarkSurfaces.borderSubtle),
        ),
      ),
      // Bottom sheets
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DarkSurfaces.level3,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Popup menus
      popupMenuTheme: PopupMenuThemeData(
        color: DarkSurfaces.level4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: DarkSurfaces.borderSubtle),
        ),
      ),
      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: DarkSurfaces.level2,
        surfaceTintColor: Colors.transparent,
      ),
      // Navigation rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: DarkSurfaces.level1,
        indicatorColor: darkColorScheme.primaryContainer,
      ),
      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: darkColorScheme.primary,
        unselectedLabelColor: darkColorScheme.onSurfaceVariant,
        indicatorColor: darkColorScheme.primary,
        dividerColor: DarkSurfaces.borderSubtle,
      ),
      // Icon theme
      iconTheme: IconThemeData(
        color: darkColorScheme.onSurfaceVariant,
      ),
      primaryIconTheme: IconThemeData(
        color: darkColorScheme.onSurface,
      ),
      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkColorScheme.primary,
        linearTrackColor: DarkSurfaces.level3,
        circularTrackColor: DarkSurfaces.level3,
      ),
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: darkColorScheme.primary,
        inactiveTrackColor: DarkSurfaces.level3,
        thumbColor: darkColorScheme.primary,
      ),
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary;
          }
          return DarkSurfaces.level5;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary.withOpacity(0.5);
          }
          return DarkSurfaces.level3;
        }),
      ),
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(darkColorScheme.onPrimary),
        side: BorderSide(color: DarkSurfaces.borderStrong, width: 2),
      ),
      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkColorScheme.primary;
          }
          return DarkSurfaces.borderStrong;
        }),
      ),
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: DarkSurfaces.level5,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DarkSurfaces.borderSubtle),
        ),
        textStyle: TextStyle(color: darkColorScheme.onSurface),
      ),
    );
  }
}
