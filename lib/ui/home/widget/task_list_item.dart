// lib/ui/home/widget/task_list_item.dart
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text.dart';
import '../../../utils/app_theme.dart';

/// ⚠️ API CHANGE from the previous version:
/// `hasTag: bool` → `tags: List<String>`.
///
/// The old card labelled every tagged task "PRIORITY" — there's no
/// priority field on NoteModel, so that label wasn't showing real data.
/// This version shows the task's actual tags instead (up to 2, with a
/// "+N" overflow chip), which is real data the app already has.
///
/// Call site update needed in home_screen.dart:
///   hasTag: note.tags.isNotEmpty   →   tags: note.tags
///
/// No due-date/time or priority UI was added — NoteModel doesn't expose
/// those fields, so nothing here is invented data.
class TaskListItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const TaskListItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.isCompleted,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .sizeOf(context)
        .width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mutedText =
    isDark ? AppColors.textSecondaryColorDark : AppColors.greyColor;
    final borderColor =
    isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceContainer;

    final baseTitleStyle = isDark
        ? AppTextStyle.bold16Black.copyWith(
        color: AppColors.textPrimaryColorDark)
        : AppTextStyle.bold16Black;

    // Cards never wrap awkwardly on narrow phones: max 2 tag chips
    // inline, overflow collapses into a single "+N" chip.
    final visibleTags = tags.take(2).toList();
    final overflowCount = tags.length - visibleTags.length;

    return AnimatedOpacity(
      opacity: isCompleted ? 0.55 : 1.0,
      duration: AppMotion.slow,
      curve: AppMotion.curve,
      child: Material(
        color: theme.cardColor,
        borderRadius: AppRadius.cardRadius,
        child: InkWell(
          onTap: onToggle,
          borderRadius: AppRadius.cardRadius,
          child: Container(
            padding: EdgeInsets.all(width * 0.045),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: borderColor, width: 1),
              boxShadow: AppElevation.card,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.12,
                  height: width * 0.12,
                  decoration:
                  BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: width * 0.06),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: AppMotion.standard,
                        curve: AppMotion.curve,
                        style: baseTitleStyle.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isCompleted ? mutedText : baseTitleStyle.color,
                        ),
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyle.regular14Grey
                              .copyWith(color: mutedText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (visibleTags.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            ...visibleTags.map((t) => _TagChip(label: t)),
                            if (overflowCount > 0)
                              _TagChip(label: '+$overflowCount'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _AnimatedCheckbox(isCompleted: isCompleted, onTap: onToggle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(label, style: AppTextStyle.bold10Primary),
    );
  }
}

/// Completion checkbox with a subtle, professional check-in animation —
/// scale + fade only, no bounce/elastic curves (per the motion system's
/// "premium, calm" rule).
class _AnimatedCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;

  const _AnimatedCheckbox({required this.isCompleted, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .sizeOf(context)
        .width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final uncheckedBorder = isDark
        ? AppColors.textMutedColorDark.withOpacity(0.5)
        : AppColors.greyLightColor.withOpacity(0.4);
    final size = width * 0.065;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.curve,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isCompleted ? primary : Colors.transparent,
          borderRadius: AppRadius.chipRadius,
          border: Border.all(
            color: isCompleted ? primary : uncheckedBorder,
            width: 2,
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, anim) =>
              ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
          child: isCompleted
              ? Icon(
            Icons.check_rounded,
            key: const ValueKey('checked'),
            color: theme.colorScheme.onPrimary,
            size: size * 0.65,
          )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}