import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/onboarding_settings.dart';
import 'package:housekeep/domain/entities/onboarding_step.dart';
import 'package:housekeep/presentation/viewmodels/onboarding_view_model.dart';
import 'package:housekeep/services/onboarding_service.dart';

import '../support/stub_onboarding_repository.dart';

void main() {
  test('completeOnboardingFlow nasconde overlay', () async {
    final repo = StubOnboardingRepository();
    final vm = OnboardingViewModel(
      repository: repo,
      service: OnboardingService(repository: repo),
      initialShowOnboarding: true,
    );
    await Future<void>.delayed(Duration.zero);
    expect(vm.showOnboardingOverlay, true);

    await vm.completeOnboardingFlow();
    expect(vm.showOnboardingOverlay, false);
    expect(vm.state.isCompleted, true);
  });

  test('updateSettings persiste', () async {
    final repo = StubOnboardingRepository();
    final vm = OnboardingViewModel(
      repository: repo,
      service: OnboardingService(repository: repo),
    );
    await Future<void>.delayed(Duration.zero);
    await vm.updateSettings(
      const OnboardingSettings(skipOnboardingAutomatically: true),
    );
    expect(vm.settings.skipOnboardingAutomatically, true);
    final fromRepo = await repo.getSettings();
    expect(fromRepo.skipOnboardingAutomatically, true);
  });

  test('markStepCompleted', () async {
    final repo = StubOnboardingRepository();
    final vm = OnboardingViewModel(
      repository: repo,
      service: OnboardingService(repository: repo),
    );
    await vm.markStepCompleted(OnboardingStep.welcome);
    expect(vm.state.isStepCompleted(OnboardingStep.welcome), true);
  });
}
