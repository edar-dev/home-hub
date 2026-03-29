import 'package:flutter/material.dart';

/// Token colore dal prototipo Stitch «PRD - Home Inventory Manager» (designTheme.namedColors).
abstract final class StitchColors {
  static const Color primary = Color(0xFF005DAC);
  static const Color primaryContainer = Color(0xFF1976D2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFDFF);
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryContainer = Color(0xFFE8DEF9);
  static const Color tertiary = Color(0xFF00695E);
  static const Color tertiaryContainer = Color(0xFF008477);
  static const Color surface = Color(0xFFFCF8FB);
  static const Color background = Color(0xFFFCF8FB);
  static const Color onSurface = Color(0xFF1C1B1D);
  static const Color onSurfaceVariant = Color(0xFF414752);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F2F5);
  static const Color surfaceContainer = Color(0xFFF0EDF0);
  static const Color surfaceContainerHigh = Color(0xFFEBE7EA);
  static const Color surfaceContainerHighest = Color(0xFFE5E1E4);
  static const Color outline = Color(0xFF717783);
  static const Color outlineVariant = Color(0xFFC1C6D4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color surfaceTint = Color(0xFF005FAF);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color amberDark = Color(0xFFD97706);

  /// [ColorScheme] light allineato al prototipo (Material 3).
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onPrimary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Color(0xFF686177),
      tertiary: tertiary,
      onTertiary: onPrimary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: Color(0xFFF9FFFC),
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainer: surfaceContainer,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerLowest: surfaceContainerLowest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: Color(0x1F000000),
      scrim: Color(0x66000000),
      inverseSurface: Color(0xFF313032),
      onInverseSurface: Color(0xFFF3F0F3),
      inversePrimary: Color(0xFFA5C8FF),
      surfaceTint: surfaceTint,
    );
  }
}
