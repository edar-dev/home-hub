import '../config/onboarding_config.dart';
import '../domain/repositories/onboarding_repository.dart';

/// Regole di business per mostrare l’onboarding fullscreen.
class OnboardingService {
  OnboardingService({required OnboardingRepository repository})
      : _repository = repository;

  final OnboardingRepository _repository;

  /// True se va mostrato onboarding al bootstrap (prima schermata).
  Future<bool> shouldShowOnboarding() async {
    final settings = await _repository.getSettings();
    if (settings.skipOnboardingAutomatically) {
      return false;
    }

    final state = await _repository.getOnboardingState();

    // Primo avvio / flusso non completato
    if (!state.isCompleted) {
      return true;
    }

    // Major feature epoch (es. FASE 4 → 5)
    if (settings.showOnboardingOnUpdate &&
        state.lastPromptedFeatureEpoch < OnboardingConfig.featureEpoch) {
      return true;
    }

    // Inattività
    if (_isInactive(state.lastAppOpenDate, OnboardingConfig.inactivityDaysThreshold)) {
      return true;
    }

    return false;
  }

  static bool _isInactive(DateTime? lastOpen, int daysThreshold) {
    if (lastOpen == null) return false;
    final now = DateTime.now();
    return now.difference(lastOpen) > Duration(days: daysThreshold);
  }
}
