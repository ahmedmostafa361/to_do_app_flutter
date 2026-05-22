// lib/ui/note/widget/action_button.dart
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text.dart';

class ActionButton extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final IconData icon;
  final Future<void> Function() onPressed; // ← stored and used

  const ActionButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.065,
      child: ElevatedButton.icon(
        onPressed: onPressed, // ← was () {} before, now wired
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.04),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, color: AppColors.whiteColor, size: width * 0.045),
        label: Text(label, style: AppTextStyle.bold14White),
      ),
    );
  }
}
