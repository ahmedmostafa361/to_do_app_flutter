// lib/ui/note/widget/color_accent_item.dart
import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';

/// API unchanged — drop-in replacement, no call-site changes needed.
class ColorAccentItem extends StatelessWidget {
  final double width;
  final Color color;
  final bool isSelected;

  const ColorAccentItem({
    super.key,
    required this.width,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Ring color matches the screen background (light or dark) so the
    // selection ring reads as a "punch-through" rather than a fixed
    // white ring that would look wrong in dark mode.
    final ringColor = Theme.of(context).scaffoldBackgroundColor;
    final size = isSelected ? width * 0.09 : width * 0.08;

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.curve,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: ringColor, width: 2.5) : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.45),
                  blurRadius: width * 0.025,
                  spreadRadius: 1.5,
                ),
              ]
            : null,
      ),
    );
  }
}