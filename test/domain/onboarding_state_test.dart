import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/animation_speed.dart';
import 'package:housekeep/domain/entities/language_code.dart';
import 'package:housekeep/domain/entities/onboarding_state.dart';
import 'package:housekeep/domain/entities/onboarding_step.dart';

void main() {
  test('initial e completionPercentage', () {
    expect(OnboardingState.initial.isCompleted, false);
    expect(OnboardingState.initial.completionPercentage, 0);

    final s = OnboardingState(
      isCompleted: false,
      completedSteps: List.generate(4, (i) => OnboardingStep.values[i]),
    );
    expect(s.completionPercentage, 50);
    expect(s.isStepCompleted(OnboardingStep.welcome), true);
    expect(s.isStepCompleted(OnboardingStep.complete), false);
  });

  test('copyWith clear flags', () {
    const base = OnboardingState(
      isCompleted: false,
      currentStep: OnboardingStep.welcome,
      tourResumeStepIndex: 2,
    );
    final cleared =
        base.copyWith(clearCurrentStep: true, clearTourResume: true);
    expect(cleared.currentStep, isNull);
    expect(cleared.tourResumeStepIndex, isNull);
  });

  test('animation e lingua', () {
    final s = OnboardingState.initial.copyWith(
      animationSpeed: AnimationSpeed.fast,
      language: LanguageCode.en,
    );
    expect(s.animationSpeed, AnimationSpeed.fast);
    expect(s.language, LanguageCode.en);
  });
}
