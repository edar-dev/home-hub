import '../entities/onboarding_settings.dart';
import '../entities/onboarding_state.dart';
import '../entities/onboarding_step.dart';

abstract class OnboardingRepository {
  Future<OnboardingState> getOnboardingState();

  Future<void> updateOnboardingState(OnboardingState state);

  Future<void> markStepCompleted(OnboardingStep step);

  Future<void> completeOnboarding();

  Future<void> resetOnboarding();

  Future<OnboardingSettings> getSettings();

  Future<void> updateSettings(OnboardingSettings settings);

  /// Aggiorna solo data ultimo avvio (inattività).
  Future<void> touchLastAppOpen();
}
