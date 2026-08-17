import 'dart:ui';

class AppColors {
  // Append only new properties to AppColors
  static const Color taskPrimaryColor = Color(0xff7C3AED);
  static const Color voicePrimaryColor = Color(0xff4648d4);
  static const Color voiceInverseSurfaceColor = Color(0xff2e3034);
  static const Color surfaceContainerHighColor = Color(0xffE1E3E4);
  static const Color accentBlueColor = Color(0xff3B82F6);
  static const Color accentAmberColor = Color(0xffF59E0B);
  static const Color accentGreenColor = Color(0xff10B981);
  static const Color primaryColor = taskPrimaryColor;
  static const Color backgroundLight = Color(0xffF8F9FA);
  static const Color surfaceContainer = Color(0xffEDEEEF);
  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color blackColor = Color(0xff191C1D);
  static const Color greyColor = Color(0xff4A4455);
  static const Color greyLightColor = Color(0xff7B7487);
  static const Color tertiaryColor = Color(0xff7D3D00);

  // ─── Design System additions (see design_system.md) ───────────────────

  // Error — fills the gap, no error color existed previously
  static const Color errorColor = Color(0xffEF4444);

  // Overdue — repurposes tertiaryColor instead of discarding it; kept
  // visually distinct from errorColor so "overdue" and "invalid input"
  // never look identical to the user
  static const Color overdueColor = tertiaryColor;

  // AI / Voice — alias so Groq-generated content and voice input share one
  // recognizable accent, without renaming the original token anywhere
  // it's already used
  static const Color aiPrimaryColor = voicePrimaryColor;

  // Priority — reuse semantic roles rather than inventing new hues
  static const Color priorityLowColor = accentGreenColor;
  static const Color priorityMediumColor = accentAmberColor;
  static const Color priorityHighColor = errorColor;
  static const Color priorityNoneColor = greyLightColor;

  // Surface (light)
  static const Color surfaceColor = whiteColor;
  static const Color surfaceElevatedColor = surfaceContainerHighColor;

  // ─── Dark theme ─────────────────────────────────────────────────────

  static const Color backgroundDark = Color(0xff121218);
  static const Color surfaceDark = Color(0xff1C1C24);
  static const Color surfaceElevatedDark = Color(0xff26262F);

  static const Color primaryColorDark = Color(0xff9F75FF);
  static const Color aiPrimaryColorDark = Color(0xff7B7DFF);
  static const Color accentBlueColorDark = Color(0xff60A5FA);
  static const Color accentGreenColorDark = Color(0xff34D399);
  static const Color accentAmberColorDark = Color(0xffFBBF24);
  static const Color errorColorDark = Color(0xffF87171);
  static const Color overdueColorDark = Color(0xffC77B3D);

  static const Color textPrimaryColorDark = Color(0xffF5F5F7);
  static const Color textSecondaryColorDark = Color(0xffABA6B3);
  static const Color textMutedColorDark = Color(0xff716C7D);

  static const Color priorityLowColorDark = accentGreenColorDark;
  static const Color priorityMediumColorDark = accentAmberColorDark;
  static const Color priorityHighColorDark = errorColorDark;
  static const Color priorityNoneColorDark = textMutedColorDark;
}