import 'package:flutter/material.dart';

/// Palette **The Organized Hive** (Material 3).
///
/// Token da [docs/brand/the-organized-hive-brand-decisions.md]. Il prototipo
/// legacy «Stitch» è sostituito da questa mappatura.
abstract final class OrganizedHiveColors {
  OrganizedHiveColors._();

  static const Color brandPrimary = Color(0xFF2F6F6B);
  static const Color brandPrimaryDark = Color(0xFF1F4F4C);
  static const Color brandSecondary = Color(0xFFC4785A);
  static const Color surfaceCanvas = Color(0xFFF7F4EF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF5C5A57);
  static const Color borderSubtle = Color(0xFFE3DFD6);
  static const Color stateSuccess = Color(0xFF5A7D5A);
  static const Color stateWarning = Color(0xFFC9A227);
  static const Color stateError = Color(0xFFC4504A);
  static const Color accentFocus = Color(0xFF2E4057);

  /// Container primario chiaro (sfondi evidenziazione).
  static const Color primaryContainer = Color(0xFFB2D1CE);
  static const Color onPrimaryContainer = Color(0xFF002020);

  /// Container secondario (terracotta soft).
  static const Color secondaryContainer = Color(0xFFF5E0D8);
  static const Color onSecondaryContainer = Color(0xFF3E1E12);

  /// Tertiary: teal profondo per FAB / accenti (contrasto su canvas).
  static const Color tertiary = Color(0xFF248A82);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFA8E8E0);
  static const Color onTertiaryContainer = Color(0xFF002E2A);

  /// [ColorScheme] light Material 3.
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: brandPrimary,
      onPrimary: surfaceElevated,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: brandSecondary,
      onSecondary: surfaceElevated,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: stateError,
      onError: surfaceElevated,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: surfaceCanvas,
      onSurface: textPrimary,
      surfaceContainerHighest: Color(0xFFD8D4CC),
      surfaceContainerHigh: Color(0xFFE3DFD6),
      surfaceContainer: Color(0xFFEAE6DD),
      surfaceContainerLow: Color(0xFFF0EDE6),
      surfaceContainerLowest: surfaceElevated,
      onSurfaceVariant: textSecondary,
      outline: Color(0xFF8E8A84),
      outlineVariant: borderSubtle,
      shadow: Color(0x1F000000),
      scrim: Color(0x66000000),
      inverseSurface: Color(0xFF31302E),
      onInverseSurface: Color(0xFFF5F3EF),
      inversePrimary: Color(0xFF86D0C8),
      surfaceTint: brandPrimary,
    );
  }

  /// Tema scuro derivato dal primario brand (contrasto leggibile).
  static ColorScheme darkScheme() {
    return ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.dark,
    );
  }

  /// Accent marketing / chip (compat con codice che usava amber Stitch).
  static const Color amberAccent = Color(0xFFC9A227);
  static const Color amberDark = Color(0xFF9A7B1A);
}
