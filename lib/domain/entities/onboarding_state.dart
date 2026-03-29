import 'animation_speed.dart';
import 'language_code.dart';
import 'onboarding_step.dart';

/// Stato persistito del percorso onboarding.
class OnboardingState {
  /// Stato iniziale (primo avvio / box vuoto).
  static const OnboardingState initial = OnboardingState(isCompleted: false);

  const OnboardingState({
    required this.isCompleted,
    this.currentStep,
    this.firstCompletedDate,
    this.lastViewedDate,
    this.completedSteps = const [],
    this.showAnimations = true,
    this.animationSpeed = AnimationSpeed.normal,
    this.language = LanguageCode.it,
    this.showContextualTooltips = true,
    this.lastAppOpenDate,
    this.lastPromptedFeatureEpoch = 0,
    this.tourResumeStepIndex,
  });

  final bool isCompleted;
  final OnboardingStep? currentStep;
  final DateTime? firstCompletedDate;
  final DateTime? lastViewedDate;
  final List<OnboardingStep> completedSteps;

  final bool showAnimations;
  final AnimationSpeed animationSpeed;
  final LanguageCode language;
  final bool showContextualTooltips;

  /// Ultimo avvio app (per inattività 30gg).
  final DateTime? lastAppOpenDate;

  /// Ultima “epoca” feature per cui è stato mostrato onboarding major.
  final int lastPromptedFeatureEpoch;

  /// Indice step tour on-demand (resumable), se null riparti da 0.
  final int? tourResumeStepIndex;

  static const int _stepCount = 8;

  bool isStepCompleted(OnboardingStep step) => completedSteps.contains(step);

  double get completionPercentage {
    if (completedSteps.isEmpty) return 0;
    return (completedSteps.length / _stepCount) * 100;
  }

  OnboardingState copyWith({
    bool? isCompleted,
    OnboardingStep? currentStep,
    DateTime? firstCompletedDate,
    DateTime? lastViewedDate,
    List<OnboardingStep>? completedSteps,
    bool? showAnimations,
    AnimationSpeed? animationSpeed,
    LanguageCode? language,
    bool? showContextualTooltips,
    DateTime? lastAppOpenDate,
    int? lastPromptedFeatureEpoch,
    int? tourResumeStepIndex,
    bool clearCurrentStep = false,
    bool clearTourResume = false,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      currentStep: clearCurrentStep ? null : (currentStep ?? this.currentStep),
      firstCompletedDate: firstCompletedDate ?? this.firstCompletedDate,
      lastViewedDate: lastViewedDate ?? this.lastViewedDate,
      completedSteps: completedSteps ?? this.completedSteps,
      showAnimations: showAnimations ?? this.showAnimations,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      language: language ?? this.language,
      showContextualTooltips:
          showContextualTooltips ?? this.showContextualTooltips,
      lastAppOpenDate: lastAppOpenDate ?? this.lastAppOpenDate,
      lastPromptedFeatureEpoch:
          lastPromptedFeatureEpoch ?? this.lastPromptedFeatureEpoch,
      tourResumeStepIndex: clearTourResume
          ? null
          : (tourResumeStepIndex ?? this.tourResumeStepIndex),
    );
  }
}
