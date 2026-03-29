import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/core/theme/app_theme.dart';
import 'package:housekeep/domain/entities/language_code.dart';
import 'package:housekeep/presentation/views/screens/onboarding/widgets/step_content_scanner.dart';

void main() {
  testWidgets('StepContentScanner mostra titolo (IT)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: StepContentScanner(
            lang: LanguageCode.it,
            showAnimation: false,
          ),
        ),
      ),
    );
    expect(find.text('Scanner codici a barre'), findsOneWidget);
  });
}
