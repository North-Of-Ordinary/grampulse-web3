import 'package:flutter/material.dart';

/// Base spacing constants using 8-pixel grid system
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Application-specific spacing utilities
class AppSpacing {
  // Base spacing (same as Spacing class)
  static const double xs = Spacing.xs;
  static const double sm = Spacing.sm;
  static const double md = Spacing.md;
  static const double lg = Spacing.lg;
  static const double xl = Spacing.xl;
  static const double xxl = Spacing.xxl;
  
  // Specific component spacings
  static const double cardPadding = md;
  static const double listItemSpacing = sm;
  static const double sectionSpacing = lg;
  static const double pagePadding = md;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  
  // Common edge insets
  static const EdgeInsets smallAllPadding = EdgeInsets.all(sm);
  static const EdgeInsets mediumAllPadding = EdgeInsets.all(md);
  static const EdgeInsets largeAllPadding = EdgeInsets.all(lg);
  
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets pageVerticalPadding = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets pagePaddingAll = EdgeInsets.all(md);
  
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: sm,
    horizontal: md,
  );
  
  static const EdgeInsets cardInnerPadding = EdgeInsets.all(md);
  
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  
  // Border radius
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 24.0;
  
  static BorderRadius get smallBorderRadius => BorderRadius.circular(borderRadiusSm);
  static BorderRadius get mediumBorderRadius => BorderRadius.circular(borderRadiusMd);
  static BorderRadius get largeBorderRadius => BorderRadius.circular(borderRadiusLg);
  static BorderRadius get extraLargeBorderRadius => BorderRadius.circular(borderRadiusXl);
  
  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Bottom navigation
  static const double bottomNavHeight = 64.0;
  static const double bottomNavItemSpacing = sm;
  
  // Fab
  static const double fabSize = 56.0;
  static const EdgeInsets fabMargin = EdgeInsets.all(md);
  
  // App bar
  static const double appBarHeight = 56.0;
  
  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = md;
  
  // Avatar/Image sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  
  // Indicator sizes for map markers and status dots
  static const double statusIndicatorSize = sm;
  static const double mapMarkerSize = 36.0;
}
