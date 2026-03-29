import 'package:housekeep/config/onboarding_config.dart';
import 'package:housekeep/domain/entities/onboarding_settings.dart';
import 'package:housekeep/domain/entities/onboarding_state.dart';
import 'package:housekeep/domain/entities/onboarding_step.dart';
import 'package:housekeep/domain/repositories/onboarding_repository.dart';

/// Repository in-memory per test widget / smoke.
class StubOnboardingRepository implements OnboardingRepository {
  OnboardingState _state = OnboardingState.initial;
  OnboardingSettings _settings = const OnboardingSettings();

  void seedState(OnboardingState state) => _state = state;

  void seedSettings(OnboardingSettings settings) => _settings = settings;

  @override
  Future<OnboardingState> getOnboardingState() async => _state;

  @override
  Future<void> updateOnboardingState(OnboardingState state) async {
    _state = state;
  }

  @override
  Future<void> markStepCompleted(OnboardingStep step) async {
    if (_state.completedSteps.contains(step)) return;
    _state = _state.copyWith(
      completedSteps: [..._state.completedSteps, step],
      lastViewedDate: DateTime.now(),
    );
  }

  @override
  Future<void> completeOnboarding() async {
    final now = DateTime.now();
    _state = _state.copyWith(
      isCompleted: true,
      firstCompletedDate: _state.firstCompletedDate ?? now,
      lastViewedDate: now,
      lastPromptedFeatureEpoch: OnboardingConfig.featureEpoch,
    );
  }

  @override
  Future<void> resetOnboarding() async {
    _state = OnboardingState.initial;
  }

  @override
  Future<OnboardingSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(OnboardingSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> touchLastAppOpen() async {
    _state = _state.copyWith(lastAppOpenDate: DateTime.now());
  }
}

StubOnboardingRepository buildStubOnboardingRepository() =>
    StubOnboardingRepository();
