import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../../domain/entities/animation_speed.dart';
import '../../../domain/entities/language_code.dart';
import '../../../domain/entities/onboarding_settings.dart';
import '../../../domain/entities/onboarding_state.dart';
import '../../../domain/entities/onboarding_step.dart';
import '../../../config/onboarding_config.dart';
import '../../../domain/repositories/onboarding_repository.dart';
import '../../../utils/onboarding_constants.dart';
import '../models/onboarding_settings_hive_model.dart';
import '../models/onboarding_state_hive_model.dart';

class LocalOnboardingRepository implements OnboardingRepository {
  LocalOnboardingRepository({
    required Box<OnboardingStateHiveModel> stateBox,
    required Box<OnboardingSettingsHiveModel> settingsBox,
  })  : _stateBox = stateBox,
        _settingsBox = settingsBox;

  final Box<OnboardingStateHiveModel> _stateBox;
  final Box<OnboardingSettingsHiveModel> _settingsBox;

  OnboardingStateHiveModel _defaultStateHive() => OnboardingStateHiveModel(
        isCompleted: false,
        completedStepIndices: const [],
        showAnimations: true,
        animationSpeedIndex: AnimationSpeed.normal.index,
        languageIndex: LanguageCode.it.index,
        showContextualTooltips: true,
        lastPromptedFeatureEpoch: 0,
      );

  OnboardingSettingsHiveModel _defaultSettingsHive() =>
      OnboardingSettingsHiveModel(
        skipOnboardingAutomatically: false,
        showOnboardingOnUpdate: true,
        animationSpeedIndex: AnimationSpeed.normal.index,
        preferredLanguageIndex: LanguageCode.it.index,
        enableAnalytics: false,
        showContextualHelp: true,
      );

  OnboardingState _entityFromHive(OnboardingStateHiveModel m) {
    OnboardingStep? current;
    final idx = m.currentStepIndex;
    if (idx != null &&
        idx >= 0 &&
        idx < OnboardingStep.values.length) {
      current = OnboardingStep.values[idx];
    }
    final completed = <OnboardingStep>[];
    for (final i in m.completedStepIndices) {
      if (i >= 0 && i < OnboardingStep.values.length) {
        completed.add(OnboardingStep.values[i]);
      }
    }
    return OnboardingState(
      isCompleted: m.isCompleted,
      currentStep: current,
      firstCompletedDate: m.firstCompletedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(m.firstCompletedAtMs!)
          : null,
      lastViewedDate: m.lastViewedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(m.lastViewedAtMs!)
          : null,
      completedSteps: completed,
      showAnimations: m.showAnimations,
      animationSpeed: _speedFromIndex(m.animationSpeedIndex),
      language: _langFromIndex(m.languageIndex),
      showContextualTooltips: m.showContextualTooltips,
      lastAppOpenDate: m.lastAppOpenAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(m.lastAppOpenAtMs!)
          : null,
      lastPromptedFeatureEpoch: m.lastPromptedFeatureEpoch,
      tourResumeStepIndex: m.tourResumeStepIndex,
    );
  }

  OnboardingSettings _settingsFromHive(OnboardingSettingsHiveModel m) {
    return OnboardingSettings(
      skipOnboardingAutomatically: m.skipOnboardingAutomatically,
      showOnboardingOnUpdate: m.showOnboardingOnUpdate,
      animationSpeed: _speedFromIndex(m.animationSpeedIndex),
      preferredLanguage: _langFromIndex(m.preferredLanguageIndex),
      enableAnalytics: m.enableAnalytics,
      showContextualHelp: m.showContextualHelp,
    );
  }

  AnimationSpeed _speedFromIndex(int i) {
    if (i >= 0 && i < AnimationSpeed.values.length) {
      return AnimationSpeed.values[i];
    }
    return AnimationSpeed.normal;
  }

  LanguageCode _langFromIndex(int i) {
    if (i >= 0 && i < LanguageCode.values.length) {
      return LanguageCode.values[i];
    }
    return LanguageCode.it;
  }

  OnboardingStateHiveModel _hiveFromEntity(OnboardingState e) {
    return OnboardingStateHiveModel(
      isCompleted: e.isCompleted,
      currentStepIndex: e.currentStep?.index,
      firstCompletedAtMs: e.firstCompletedDate?.millisecondsSinceEpoch,
      lastViewedAtMs: e.lastViewedDate?.millisecondsSinceEpoch,
      completedStepIndices: e.completedSteps.map((s) => s.index).toList(),
      showAnimations: e.showAnimations,
      animationSpeedIndex: e.animationSpeed.index,
      languageIndex: e.language.index,
      showContextualTooltips: e.showContextualTooltips,
      lastAppOpenAtMs: e.lastAppOpenDate?.millisecondsSinceEpoch,
      lastPromptedFeatureEpoch: e.lastPromptedFeatureEpoch,
      tourResumeStepIndex: e.tourResumeStepIndex,
    );
  }

  OnboardingSettingsHiveModel _hiveFromSettings(OnboardingSettings s) {
    return OnboardingSettingsHiveModel(
      skipOnboardingAutomatically: s.skipOnboardingAutomatically,
      showOnboardingOnUpdate: s.showOnboardingOnUpdate,
      animationSpeedIndex: s.animationSpeed.index,
      preferredLanguageIndex: s.preferredLanguage.index,
      enableAnalytics: s.enableAnalytics,
      showContextualHelp: s.showContextualHelp,
    );
  }

  @override
  Future<OnboardingState> getOnboardingState() async {
    try {
      final raw = _stateBox.get(kOnboardingStateKey);
      if (raw == null) {
        final seed = _defaultStateHive();
        await _stateBox.put(kOnboardingStateKey, seed);
        return _entityFromHive(seed);
      }
      return _entityFromHive(raw);
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.getOnboardingState: $e\n$st');
      return OnboardingState.initial;
    }
  }

  @override
  Future<void> updateOnboardingState(OnboardingState state) async {
    try {
      await _stateBox.put(kOnboardingStateKey, _hiveFromEntity(state));
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.updateOnboardingState: $e\n$st');
    }
  }

  @override
  Future<void> markStepCompleted(OnboardingStep step) async {
    final current = await getOnboardingState();
    if (current.completedSteps.contains(step)) {
      return;
    }
    final next = current.copyWith(
      completedSteps: [...current.completedSteps, step],
      lastViewedDate: DateTime.now(),
    );
    await updateOnboardingState(next);
  }

  @override
  Future<void> completeOnboarding() async {
    final now = DateTime.now();
    final current = await getOnboardingState();
    await updateOnboardingState(
      current.copyWith(
        isCompleted: true,
        firstCompletedDate: current.firstCompletedDate ?? now,
        lastViewedDate: now,
        lastPromptedFeatureEpoch: OnboardingConfig.featureEpoch,
      ),
    );
  }

  @override
  Future<void> resetOnboarding() async {
    try {
      await _stateBox.put(kOnboardingStateKey, _defaultStateHive());
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.resetOnboarding: $e\n$st');
    }
  }

  @override
  Future<OnboardingSettings> getSettings() async {
    try {
      final raw = _settingsBox.get(kOnboardingSettingsKey);
      if (raw == null) {
        final seed = _defaultSettingsHive();
        await _settingsBox.put(kOnboardingSettingsKey, seed);
        return _settingsFromHive(seed);
      }
      return _settingsFromHive(raw);
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.getSettings: $e\n$st');
      return const OnboardingSettings();
    }
  }

  @override
  Future<void> updateSettings(OnboardingSettings settings) async {
    try {
      await _settingsBox.put(
        kOnboardingSettingsKey,
        _hiveFromSettings(settings),
      );
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.updateSettings: $e\n$st');
    }
  }

  @override
  Future<void> touchLastAppOpen() async {
    try {
      final current = await getOnboardingState();
      await updateOnboardingState(
        current.copyWith(lastAppOpenDate: DateTime.now()),
      );
    } catch (e, st) {
      debugPrint('LocalOnboardingRepository.touchLastAppOpen: $e\n$st');
    }
  }
}
