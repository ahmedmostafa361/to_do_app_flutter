import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Design tokens: spacing, radius, elevation, motion.
/// See design_system.md §5 for rationale. Nothing here should be
/// hand-typed as a raw value in screen/widget code — reference these
/// constants instead, so a future scale change is a one-line edit.

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
}

class AppRadius {
  static const double chip = 8;
  static const double button = 12;
  static const double card = 16;

  // Nothing above 16 — avoids the "overly rounded" look the brief flagged.

  static const BorderRadius chipRadius = BorderRadius.all(
    Radius.circular(chip),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
}

class AppElevation {
  // One soft shadow style — never stack multiple shadows on one surface.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity black
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);

  // easeOutCubic / easeInOutCubic only — no bounce/elastic curves, which
  // read as playful and conflict with "premium, calm, professional."
  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveInOut = Curves.easeInOutCubic;
}

/// NOTE: no existing theme_data/app_theme file was shared, so this is a
/// fresh file, not a merge. If you already have one elsewhere in the
/// project, send it and I'll fold this into it instead of introducing
/// a second theme file.
class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    cardColor: AppColors.surfaceColor,
    dividerColor: AppColors.surfaceContainerHighColor,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.aiPrimaryColor,
      surface: AppColors.surfaceColor,
      error: AppColors.errorColor,
      onPrimary: AppColors.whiteColor,
      onSecondary: AppColors.whiteColor,
      onSurface: AppColors.blackColor,
      onError: AppColors.whiteColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      titleTextStyle: AppTextStyle.bold18Black,
      iconTheme: const IconThemeData(color: AppColors.blackColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
        textStyle: AppTextStyle.bold16White,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceDark,
    dividerColor: AppColors.surfaceElevatedDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColorDark,
      secondary: AppColors.aiPrimaryColorDark,
      surface: AppColors.surfaceDark,
      error: AppColors.errorColorDark,
      onPrimary: AppColors.blackColor,
      onSecondary: AppColors.blackColor,
      onSurface: AppColors.textPrimaryColorDark,
      onError: AppColors.blackColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      titleTextStyle: AppTextStyle.bold18Black.copyWith(
        color: AppColors.textPrimaryColorDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimaryColorDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Light lavender primary in dark mode → black text reads
        // better than white here; check this against real content.
        backgroundColor: AppColors.primaryColorDark,
        foregroundColor: AppColors.blackColor,
        textStyle: AppTextStyle.bold16White.copyWith(
          color: AppColors.blackColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  );
}
