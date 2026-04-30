import 'package:flutter/material.dart';

import 'app_theme_extension.dart';

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.dark(
      primary: Color(0xFF2E86DE),
      secondary: Color(0xFFA0B4C8),
      tertiary: Color(0xFFC56E00),
      surface: Color(0xFF1C2128),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF0C1420),
      onSurface: Color(0xFFF3F7FC),
      error: Color(0xFFE68F8F),
      onError: Color(0xFF2B1212),
    );

    const appTheme = AppThemeExtension(
      appBackground: Color(0xFF11161C),
      surfacePrimary: Color(0xFF171C22),
      surfaceSecondary: Color(0xFF1D2430),
      surfaceTertiary: Color(0xFF263244),
      borderSubtle: Color(0xFF2A3340),
      borderStrong: Color(0xFF33465E),
      textPrimary: Color(0xFFF3F7FC),
      textSecondary: Color(0xFFD2D9E3),
      textMuted: Color(0xFF7D8794),
      accentWarm: Color(0xFFFFB86B),
      successSoft: Color(0xFF9BBEFF),
      errorSoft: Color(0xFFFFD6D6),
      primaryGlow: Color(0xFF0A6DFF),
      secondaryGlow: Color(0xFFFF5A1F),
      heroGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF12253C), Color(0xFF0E1D31), Color(0xFF0A1524)],
      ),
      panelShadow: [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 40,
          offset: Offset(0, 24),
        ),
      ],
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appTheme.appBackground,
      extensions: const [appTheme],
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        displayMedium: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFD2D9E3),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFD2D9E3),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF7D8794),
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7D8794),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1D2430),
        hintStyle: TextStyle(color: Color(0xFF7D8794)),
        prefixIconColor: Color(0xFF7D8794),
        suffixIconColor: Color(0xFF7D8794),
        contentPadding: EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFF33465E)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFF33465E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFF2E86DE)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFE68F8F)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Color(0xFFE68F8F)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: const Color(0xFF28405C),
          disabledForegroundColor: const Color(0xFFD2D9E3),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: const BorderSide(color: Color(0xFF3A4C63)),
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        color: appTheme.surfacePrimary,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: appTheme.borderSubtle),
        ),
      ),
    );
  }
}
