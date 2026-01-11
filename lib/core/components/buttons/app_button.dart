import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/app_text_styles.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
}

class AppButton extends StatelessWidget {
  final String label;
  final AppButtonType type;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final double minWidth;
  final EdgeInsets? padding;
  
  const AppButton({
    super.key,
    required this.label,
    this.type = AppButtonType.primary,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height = 48.0,
    this.minWidth = 120.0,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;
    
    // Define button styles based on type
    ButtonStyle getButtonStyle() {
      switch (type) {
        case AppButtonType.primary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            disabledBackgroundColor: theme.disabledColor,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.button,
            minimumSize: Size(minWidth, height),
            padding: padding ?? EdgeInsets.zero,
          );
        case AppButtonType.secondary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            disabledBackgroundColor: theme.disabledColor,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.button,
            minimumSize: Size(minWidth, height),
            padding: padding ?? EdgeInsets.zero,
          );
        case AppButtonType.outline:
          return OutlinedButton.styleFrom(
            side: BorderSide(color: isDisabled ? theme.disabledColor : theme.primaryColor),
            foregroundColor: theme.primaryColor,
            textStyle: AppTextStyles.button.copyWith(color: theme.primaryColor),
            minimumSize: Size(minWidth, height),
            padding: padding ?? EdgeInsets.zero,
          );
        case AppButtonType.text:
          return TextButton.styleFrom(
            foregroundColor: theme.primaryColor,
            textStyle: AppTextStyles.button.copyWith(color: theme.primaryColor),
            minimumSize: Size(minWidth, height),
            padding: padding ?? EdgeInsets.zero,
          );
        case AppButtonType.danger:
          return ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            disabledBackgroundColor: theme.disabledColor,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.button,
            minimumSize: Size(minWidth, height),
            padding: padding ?? EdgeInsets.zero,
          );
      }
    }
    
    // Button content
    Widget buttonChild;
    if (isLoading) {
      buttonChild = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.0,
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      buttonChild = Text(label);
    }
    
    // Button widget based on type
    Widget buttonWidget;
    switch (type) {
      case AppButtonType.outline:
        buttonWidget = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        buttonWidget = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
      default:
        buttonWidget = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
    }
    
    // Apply full width if needed
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }
    
    return buttonWidget;
  }
}
