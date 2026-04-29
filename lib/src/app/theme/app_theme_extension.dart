import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.appBackground,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accentWarm,
    required this.successSoft,
    required this.errorSoft,
    required this.primaryGlow,
    required this.secondaryGlow,
    required this.heroGradient,
    required this.panelShadow,
  });

  final Color appBackground;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accentWarm;
  final Color successSoft;
  final Color errorSoft;
  final Color primaryGlow;
  final Color secondaryGlow;
  final Gradient heroGradient;
  final List<BoxShadow> panelShadow;

  @override
  AppThemeExtension copyWith({
    Color? appBackground,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accentWarm,
    Color? successSoft,
    Color? errorSoft,
    Color? primaryGlow,
    Color? secondaryGlow,
    Gradient? heroGradient,
    List<BoxShadow>? panelShadow,
  }) {
    return AppThemeExtension(
      appBackground: appBackground ?? this.appBackground,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accentWarm: accentWarm ?? this.accentWarm,
      successSoft: successSoft ?? this.successSoft,
      errorSoft: errorSoft ?? this.errorSoft,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      secondaryGlow: secondaryGlow ?? this.secondaryGlow,
      heroGradient: heroGradient ?? this.heroGradient,
      panelShadow: panelShadow ?? this.panelShadow,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accentWarm: Color.lerp(accentWarm, other.accentWarm, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      secondaryGlow: Color.lerp(secondaryGlow, other.secondaryGlow, t)!,
      heroGradient: other.heroGradient,
      panelShadow: other.panelShadow,
    );
  }
}

extension AppThemeBuildContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
