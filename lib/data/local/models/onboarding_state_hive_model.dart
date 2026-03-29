import 'package:hive/hive.dart';

part 'onboarding_state_hive_model.g.dart';

@HiveType(typeId: 8)
class OnboardingStateHiveModel extends HiveObject {
  OnboardingStateHiveModel({
    required this.isCompleted,
    this.currentStepIndex,
    this.firstCompletedAtMs,
    this.lastViewedAtMs,
    this.completedStepIndices = const [],
    required this.showAnimations,
    required this.animationSpeedIndex,
    required this.languageIndex,
    required this.showContextualTooltips,
    this.lastAppOpenAtMs,
    this.lastPromptedFeatureEpoch = 0,
    this.tourResumeStepIndex,
  });

  @HiveField(0)
  bool isCompleted;

  @HiveField(1)
  int? currentStepIndex;

  @HiveField(2)
  int? firstCompletedAtMs;

  @HiveField(3)
  int? lastViewedAtMs;

  @HiveField(4)
  List<int> completedStepIndices;

  @HiveField(5)
  bool showAnimations;

  @HiveField(6)
  int animationSpeedIndex;

  @HiveField(7)
  int languageIndex;

  @HiveField(8)
  bool showContextualTooltips;

  @HiveField(9)
  int? lastAppOpenAtMs;

  @HiveField(10)
  int lastPromptedFeatureEpoch;

  @HiveField(11)
  int? tourResumeStepIndex;
}
