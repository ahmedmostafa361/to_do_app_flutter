// lib/ui/note/widget/symbol_selector_item.dart
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_theme.dart';

/// API unchanged — drop-in replacement, no call-site changes needed.
class SymbolSelectorItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final bool isSelected;

  const SymbolSelectorItem({
    super.key,
    required this.width,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    // No dedicated "surfaceContainerDark" token exists yet, so
    // surfaceElevatedDark is used as the closest equivalent unselected
    // surface — same role as surfaceContainer plays in light mode.
    final unselectedBg = isDark
        ? AppColors.surfaceElevatedDark
        : AppColors.surfaceContainer;
    final unselectedIcon = isDark
        ? AppColors.textSecondaryColorDark
        : AppColors.greyColor;

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.curve,
      width: width * 0.13,
      height: width * 0.13,
      decoration: BoxDecoration(
        color: isSelected ? primary.withOpacity(0.14) : unselectedBg,
        borderRadius: AppRadius.buttonRadius,
        border: Border.all(
          color: isSelected ? primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? primary : unselectedIcon,
        size: width * 0.055,
      ),
    );
  }
}