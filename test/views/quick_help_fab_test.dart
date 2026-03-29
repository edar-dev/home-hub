import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/viewmodels/home_shell_tab_controller.dart';
import 'package:housekeep/presentation/viewmodels/onboarding_view_model.dart';
import 'package:housekeep/presentation/views/widgets/quick_help/quick_help_fab.dart';
import 'package:housekeep/services/onboarding_service.dart';
import 'package:provider/provider.dart';

import '../support/stub_onboarding_repository.dart';

void main() {
  testWidgets('QuickHelpFab icona aiuto quando onboarding off', (tester) async {
    final repo = StubOnboardingRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeShellTabController>(
              create: (_) => HomeShellTabController(),
            ),
            ChangeNotifierProvider<OnboardingViewModel>(
              create: (_) => OnboardingViewModel(
                repository: repo,
                service: OnboardingService(repository: repo),
                initialShowOnboarding: false,
              ),
            ),
          ],
          child: const Scaffold(
            body: Stack(
              children: [
                QuickHelpFab(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.help_outline), findsOneWidget);
  });
}
