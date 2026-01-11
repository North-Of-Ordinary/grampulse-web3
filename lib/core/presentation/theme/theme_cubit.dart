import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A Cubit for managing app theme mode (light/dark)
/// FORCED dark mode for Grok-inspired UI - ignores saved preference
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  static const String _themeVersionKey = 'theme_version';
  static const int _currentThemeVersion = 2; // Increment to force dark mode reset
  
  ThemeCubit() : super(ThemeMode.dark) {
    _loadTheme();
  }

  /// Load theme - FORCE dark mode and clear old preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getInt(_themeVersionKey) ?? 0;
      
      // Force dark mode if theme version is outdated (reset old light mode preferences)
      if (savedVersion < _currentThemeVersion) {
        await prefs.setInt(_themeVersionKey, _currentThemeVersion);
        await prefs.setInt(_themeKey, ThemeMode.dark.index);
        emit(ThemeMode.dark);
      } else {
        // Only use saved preference if version matches
        final themeIndex = prefs.getInt(_themeKey);
        if (themeIndex != null) {
          emit(ThemeMode.values[themeIndex]);
        } else {
          emit(ThemeMode.dark);
        }
      }
    } catch (e) {
      emit(ThemeMode.dark);
    }
  }

  /// Toggle between light and dark modes
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme(newMode);
    emit(newMode);
  }

  /// Set a specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    await _saveTheme(mode);
    emit(mode);
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Check if currently in dark mode
  bool get isDarkMode => state == ThemeMode.dark;
}
