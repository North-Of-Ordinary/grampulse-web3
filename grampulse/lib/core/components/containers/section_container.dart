import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/app_text_styles.dart';

class SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final EdgeInsets padding;
  
  const SectionContainer({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onActionTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitleBold,
                ),
                if (actionLabel != null && onActionTap != null)
                  GestureDetector(
                    onTap: onActionTap,
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}
