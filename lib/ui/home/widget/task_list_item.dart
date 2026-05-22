import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text.dart';

class TaskListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool hasTag;
  final bool isCompleted;
  final VoidCallback? onToggle; // ✅ NEW

  const TaskListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.hasTag,
    required this.isCompleted,
    this.onToggle, // ✅ NEW
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: onToggle, // ✅ tapping anywhere on the card toggles it
      child: Opacity(
        opacity: isCompleted ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(width * 0.03),
            border: Border.all(
              color: AppColors.surfaceContainer.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.04),
                blurRadius: width * 0.06,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: width * 0.12,
                height: width * 0.12,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: width * 0.06),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: isCompleted
                          ? AppTextStyle.bold18Black.copyWith(
                              decoration: TextDecoration.lineThrough,
                            )
                          : AppTextStyle.bold18Black,
                    ),
                    SizedBox(height: width * 0.01),
                    Text(subtitle, style: AppTextStyle.regular14Grey),
                  ],
                ),
              ),
              SizedBox(width: width * 0.02),
              Row(
                children: [
                  if (hasTag) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.03,
                        vertical: width * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(width * 0.04),
                      ),
                      child: Text(
                        'PRIORITY',
                        style: AppTextStyle.bold10Primary,
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                  ],
                  // ✅ Checkbox is now also individually tappable
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: width * 0.06,
                      height: width * 0.06,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primaryColor
                            : AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(width * 0.008),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primaryColor
                              : AppColors.greyLightColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: AppColors.whiteColor,
                              size: width * 0.04,
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
