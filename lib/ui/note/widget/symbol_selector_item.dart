import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

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
    return Container(
      width: width * 0.13,
      height: width * 0.13,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.2)
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        color: isSelected ? AppColors.primaryColor : AppColors.greyColor,
        size: width * 0.055,
      ),
    );
  }
}
