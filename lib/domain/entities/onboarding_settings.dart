import 'animation_speed.dart';
import 'language_code.dart';

/// Preferenze utente per onboarding e aiuto.
class OnboardingSettings {
  const OnboardingSettings({
    this.skipOnboardingAutomatically = false,
    this.showOnboardingOnUpdate = true,
    this.animationSpeed = AnimationSpeed.normal,
    this.preferredLanguage = LanguageCode.it,
    this.enableAnalytics = false,
    this.showContextualHelp = true,
  });

  final bool skipOnboardingAutomatically;
  final bool showOnboardingOnUpdate;
  final AnimationSpeed animationSpeed;
  final LanguageCode preferredLanguage;
  final bool enableAnalytics;
  final bool showContextualHelp;

  OnboardingSettings copyWith({
    bool? skipOnboardingAutomatically,
    bool? showOnboardingOnUpdate,
    AnimationSpeed? animationSpeed,
    LanguageCode? preferredLanguage,
    bool? enableAnalytics,
    bool? showContextualHelp,
  }) {
    return OnboardingSettings(
      skipOnboardingAutomatically:
          skipOnboardingAutomatically ?? this.skipOnboardingAutomatically,
      showOnboardingOnUpdate:
          showOnboardingOnUpdate ?? this.showOnboardingOnUpdate,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      showContextualHelp: showContextualHelp ?? this.showContextualHelp,
    );
  }
}
