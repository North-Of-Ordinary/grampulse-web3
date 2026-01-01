import 'package:flutter/foundation.dart';

/// Application configuration constants
/// 
/// This file contains configuration flags that control app behavior.
/// IMPORTANT: Review these settings before production deployment.
class AppConfig {
  AppConfig._();

  /// Enable authentication bypass for testing purposes.
  /// 
  /// When enabled AND running in debug mode, a "Skip for Testing" button
  /// will appear on authentication screens allowing quick access to the app.
  /// 
  /// SECURITY: This is automatically disabled in release builds via kDebugMode.
  /// To completely remove this feature, set this to false OR remove the
  /// [TestAuthBypassButton] widget from authentication screens.
  /// 
  /// Default test user: citizen role with complete profile
  static const bool enableAuthBypass = true;

  /// Returns true if auth bypass should be shown.
  /// Only enabled when both [enableAuthBypass] is true AND app is in debug mode.
  static bool get showAuthBypass => enableAuthBypass && kDebugMode;
}
