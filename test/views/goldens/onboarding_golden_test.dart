import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:housekeep/core/theme/app_theme.dart';
import 'package:housekeep/domain/entities/language_code.dart';
import 'package:housekeep/presentation/views/screens/onboarding/widgets/step_content_completion.dart';
import 'package:housekeep/presentation/views/screens/onboarding/widgets/step_content_scanner.dart';
import 'package:housekeep/presentation/views/screens/onboarding/widgets/step_content_welcome.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  const lang = LanguageCode.it;
  const surface = Size(400, 520);

  testGoldens('Onboarding Welcome — light', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentWelcome(
        lang: lang,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildLightTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_welcome_light');
  });

  testGoldens('Onboarding Welcome — dark', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentWelcome(
        lang: lang,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildDarkTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_welcome_dark');
  });

  testGoldens('Onboarding Scanner — light', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentScanner(
        lang: lang,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildLightTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_scanner_light');
  });

  testGoldens('Onboarding Scanner — dark', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentScanner(
        lang: lang,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildDarkTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_scanner_dark');
  });

  testGoldens('Onboarding Completion — light', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentCompletion(
        lang: lang,
        showConfetti: false,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildLightTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_completion_light');
  });

  testGoldens('Onboarding Completion — dark', (tester) async {
    await tester.pumpWidgetBuilder(
      const StepContentCompletion(
        lang: lang,
        showConfetti: false,
        showAnimation: false,
      ),
      wrapper: materialAppWrapper(theme: buildDarkTheme()),
      surfaceSize: surface,
    );
    await tester.pumpAndSettle();
    await screenMatchesGolden(tester, 'onboarding_completion_dark');
  });
}
