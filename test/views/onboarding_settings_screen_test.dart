import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/viewmodels/onboarding_view_model.dart';
import 'package:housekeep/presentation/views/screens/settings/onboarding_settings_screen.dart';
import 'package:housekeep/services/onboarding_service.dart';
import 'package:provider/provider.dart';

import '../support/stub_onboarding_repository.dart';

void main() {
  testWidgets('OnboardingSettingsScreen titolo', (tester) async {
    final repo = StubOnboardingRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => OnboardingViewModel(
            repository: repo,
            service: OnboardingService(repository: repo),
          ),
          child: const OnboardingSettingsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Onboarding'), findsWidgets);
  });
}
