import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';

/// A reusable, professional back button widget.
/// 
/// Clean, modern design that can be used across screens and AppBars consistently.
/// Supports both icon-only and icon + label variants.
/// 
/// Usage:
/// ```dart
/// // Icon only (default)
/// AppBackButton()
/// 
/// // With label
/// AppBackButton(showLabel: true)
/// 
/// // Custom label
/// AppBackButton(showLabel: true, label: 'Cancel')
/// 
/// // In AppBar
/// AppBar(leading: AppBackButton())
/// ```
class AppBackButton extends StatelessWidget {
  /// Whether to show a text label alongside the icon.
  final bool showLabel;
  
  /// Custom label text. Defaults to 'Back'.
  final String label;
  
  /// Custom callback. If null, uses Navigator.pop() or context.pop().
  final VoidCallback? onPressed;
  
  /// Icon color override. Uses theme's onSurface color by default.
  final Color? iconColor;
  
  /// Whether to use a circular container around the icon.
  final bool useContainer;

  const AppBackButton({
    super.key,
    this.showLabel = false,
    this.label = 'Back',
    this.onPressed,
    this.iconColor,
    this.useContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.onSurface;
    
    void handlePress() {
      if (onPressed != null) {
        onPressed!();
      } else {
        // Try GoRouter first, fallback to Navigator
        if (context.canPop()) {
          context.pop();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    }

    if (showLabel) {
      return TextButton.icon(
        onPressed: handlePress,
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          size: 18,
          color: color,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (useContainer) {
      return GestureDetector(
        onTap: handlePress,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: 18,
            color: color,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: handlePress,
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        size: 20,
        color: color,
      ),
      tooltip: label,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  
  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : _buildButtonContent(),
      ),
    );
  }
  
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: Spacing.sm),
          Text(label),
        ],
      );
    } else {
      return Text(label);
    }
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  
  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : _buildButtonContent(),
      ),
    );
  }
  
  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: Spacing.sm),
          Text(label),
        ],
      );
    } else {
      return Text(label);
    }
  }
}

class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const TextActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: Spacing.xs),
              Text(label),
            ],
          )
        : Text(label),
    );
  }
}
