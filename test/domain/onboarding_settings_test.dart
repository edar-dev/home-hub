import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/animation_speed.dart';
import 'package:housekeep/domain/entities/language_code.dart';
import 'package:housekeep/domain/entities/onboarding_settings.dart';

void main() {
  test('defaults e copyWith', () {
    const s = OnboardingSettings();
    expect(s.skipOnboardingAutomatically, false);
    expect(s.showOnboardingOnUpdate, true);
    expect(s.animationSpeed, AnimationSpeed.normal);
    expect(s.preferredLanguage, LanguageCode.it);

    final u = s.copyWith(
      skipOnboardingAutomatically: true,
      enableAnalytics: true,
    );
    expect(u.skipOnboardingAutomatically, true);
    expect(u.enableAnalytics, true);
    expect(u.showOnboardingOnUpdate, true);
  });
}
