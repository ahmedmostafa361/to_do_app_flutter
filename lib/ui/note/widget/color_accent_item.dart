import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

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
    return Container(
      width: width * 0.08,
      height: width * 0.08,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppColors.backgroundLight, width: 2)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: width * 0.02,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}
