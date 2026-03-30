import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'stitch_color_scheme.dart';

ThemeData buildLightTheme() {
  final scheme = StitchColors.lightScheme();
  final baseText = GoogleFonts.interTextTheme();
  final textTheme = baseText.copyWith(
    displayLarge: GoogleFonts.manrope(textStyle: baseText.displayLarge),
    displayMedium: GoogleFonts.manrope(textStyle: baseText.displayMedium),
    displaySmall: GoogleFonts.manrope(textStyle: baseText.displaySmall),
    headlineLarge: GoogleFonts.manrope(
      textStyle: baseText.headlineLarge,
      fontWeight: FontWeight.w800,
    ),
    headlineMedium: GoogleFonts.manrope(
      textStyle: baseText.headlineMedium,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: GoogleFonts.manrope(
      textStyle: baseText.headlineSmall,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.manrope(
      textStyle: baseText.titleLarge,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: GoogleFonts.manrope(
      textStyle: baseText.titleMedium,
      fontWeight: FontWeight.w700,
    ),
    titleSmall: GoogleFonts.manrope(
      textStyle: baseText.titleSmall,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: GoogleFonts.inter(textStyle: baseText.bodyLarge, height: 1.5),
    bodyMedium: GoogleFonts.inter(textStyle: baseText.bodyMedium, height: 1.5),
    bodySmall: GoogleFonts.inter(textStyle: baseText.bodySmall, height: 1.45),
    labelLarge: GoogleFonts.inter(
      textStyle: baseText.labelLarge,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: GoogleFonts.inter(
      textStyle: baseText.labelMedium,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: GoogleFonts.inter(
      textStyle: baseText.labelSmall,
      fontWeight: FontWeight.w500,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLowest,
      elevation: 0,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: const StadiumBorder(),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.tertiary,
      foregroundColor: scheme.onTertiary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLowest,
      elevation: 0,
      height: 68,
      indicatorColor: StitchColors.primary.withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.primary, size: 24);
        }
        return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainer,
      selectedColor: scheme.primary,
      disabledColor: scheme.surfaceContainerHigh,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
      secondaryLabelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: scheme.onPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: StitchColors.primaryContainer,
    brightness: Brightness.dark,
  );
  final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
  final textTheme = baseText.copyWith(
    headlineSmall: GoogleFonts.manrope(
      textStyle: baseText.headlineSmall,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.manrope(
      textStyle: baseText.titleLarge,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: GoogleFonts.manrope(
      textStyle: baseText.titleMedium,
      fontWeight: FontWeight.w700,
    ),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: const CardThemeData(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.tertiary,
      foregroundColor: scheme.onTertiary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      elevation: 0,
      height: 68,
      indicatorColor: scheme.primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: scheme.primary, size: 24);
        }
        return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
      }),
    ),
  );
}
