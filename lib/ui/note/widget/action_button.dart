// lib/ui/note/widget/action_button.dart
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text.dart';
import '../../../utils/app_theme.dart';

/// A compact "AI action" button (Summarize, Generate Tags, ...).
///
/// Styled with the AI/Voice accent color so these read as AI-powered
/// actions, visually distinct from the primary "Create Task" button
/// elsewhere on screen — reinforces the AI identity per the design brief.
///
/// API note: constructor is 100% backward compatible with the previous
/// version. `isLoading` is new and optional (defaults to false) — when
/// true it shows an inline spinner and disables the tap, which lets you
/// delete the separate `_loadingButton()` helper in create_note_screen.dart
/// if you want, though nothing requires that change.
class ActionButton extends StatefulWidget {
  final double width;
  final double height;
  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.width,
    required this.height,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.isLoading) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark
        ? AppColors.aiPrimaryColorDark
        : AppColors.aiPrimaryColor;

    return Semantics(
      button: true,
      enabled: !widget.isLoading,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.curve,
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.curve,
            height: widget.height * 0.065,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: accent.withOpacity(widget.isLoading ? 0.06 : 0.1),
              borderRadius: AppRadius.buttonRadius,
              border: Border.all(color: accent.withOpacity(0.25), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: widget.width * 0.04,
                    height: widget.width * 0.04,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  )
                else
                  Icon(widget.icon, color: accent, size: widget.width * 0.045),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTextStyle.bold14White.copyWith(color: accent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}