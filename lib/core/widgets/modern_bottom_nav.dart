import 'package:flutter/material.dart';
import 'package:grampulse/core/theme/color_schemes.dart';

/// A modern, anchored bottom navigation bar with enhanced visibility.
/// Features a pill-shaped active indicator and top accent line.
class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernBottomNavItem> items;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Use layered dark surfaces for visual hierarchy
    final backgroundColor = isDark 
        ? DarkSurfaces.level0 // True black background
        : Colors.white;
    
    final activeColor = colorScheme.primary;
    
    final inactiveColor = isDark 
        ? const Color(0xFF8E8E93) // iOS-like grey for dark mode
        : const Color(0xFF636366); // Subtle grey for light mode
    
    final dividerColor = isDark
        ? DarkSurfaces.borderMedium
        : Colors.black.withOpacity(0.06);

    final activeIndicatorColor = isDark
        ? colorScheme.primary.withOpacity(0.20)
        : colorScheme.primary.withOpacity(0.12);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              
              return Expanded(
                child: RepaintBoundary(
                  child: _NavItem(
                    icon: item.icon,
                    activeIcon: item.activeIcon ?? item.icon,
                    label: item.label,
                    isSelected: isSelected,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    activeIndicatorColor: activeIndicatorColor,
                    onTap: () => onTap(index),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeIndicatorColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeIndicatorColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active indicator pill with icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? activeIndicatorColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for bottom nav items
class ModernBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const ModernBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
