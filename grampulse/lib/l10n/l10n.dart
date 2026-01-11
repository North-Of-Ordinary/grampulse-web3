import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

class L10n {
  static const all = [
    Locale('en', ''), // English
    Locale('ta', ''), // Tamil
    Locale('ml', ''), // Malayalam
    Locale('kn', ''), // Kannada
    Locale('hi', ''), // Hindi
  ];
  
  static String getFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'ta':
        return '🇮🇳';
      case 'ml':
        return '🇮🇳';
      case 'kn':
        return '🇮🇳';
      case 'hi':
        return '🇮🇳';
      default:
        return '🏳️';
    }
  }
  
  static String getName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ta':
        return 'Tamil (தமிழ்)';
      case 'ml':
        return 'Malayalam (മലയാളം)';
      case 'kn':
        return 'Kannada (ಕನ್ನಡ)';
      case 'hi':
        return 'Hindi (हिंदी)';
      default:
        return code;
    }
  }
}
