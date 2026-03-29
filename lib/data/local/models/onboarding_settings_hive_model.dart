import 'package:hive/hive.dart';

part 'onboarding_settings_hive_model.g.dart';

@HiveType(typeId: 9)
class OnboardingSettingsHiveModel extends HiveObject {
  OnboardingSettingsHiveModel({
    required this.skipOnboardingAutomatically,
    required this.showOnboardingOnUpdate,
    required this.animationSpeedIndex,
    required this.preferredLanguageIndex,
    required this.enableAnalytics,
    required this.showContextualHelp,
  });

  @HiveField(0)
  bool skipOnboardingAutomatically;

  @HiveField(1)
  bool showOnboardingOnUpdate;

  @HiveField(2)
  int animationSpeedIndex;

  @HiveField(3)
  int preferredLanguageIndex;

  @HiveField(4)
  bool enableAnalytics;

  @HiveField(5)
  bool showContextualHelp;
}
