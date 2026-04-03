import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/data/local/models/onboarding_settings_hive_model.dart';
import 'package:housekeep/data/local/models/onboarding_state_hive_model.dart';
import 'package:housekeep/data/local/repositories/local_onboarding_repository.dart';
import 'package:housekeep/domain/entities/onboarding_step.dart';
import 'package:housekeep/utils/onboarding_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<OnboardingStateHiveModel> stateBox;
  late Box<OnboardingSettingsHiveModel> settingsBox;
  late LocalOnboardingRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('housekeep_onb_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(OnboardingStateHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(OnboardingSettingsHiveModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    final ts = DateTime.now().microsecondsSinceEpoch;
    stateBox = await Hive.openBox<OnboardingStateHiveModel>('ob_state_$ts');
    settingsBox = await Hive.openBox<OnboardingSettingsHiveModel>('ob_set_$ts');
    repository = LocalOnboardingRepository(
      stateBox: stateBox,
      settingsBox: settingsBox,
    );
  });

  tearDown(() async {
    await stateBox.close();
    await settingsBox.close();
    await Hive.deleteBoxFromDisk(stateBox.name);
    await Hive.deleteBoxFromDisk(settingsBox.name);
  });

  test('primo get: seed e stato coerente', () async {
    final s = await repository.getOnboardingState();
    expect(s.isCompleted, false);
    expect(await repository.getSettings(), isNotNull);
  });

  test('markStepCompleted e completeOnboarding', () async {
    await repository.markStepCompleted(OnboardingStep.welcome);
    var s = await repository.getOnboardingState();
    expect(s.isStepCompleted(OnboardingStep.welcome), true);

    await repository.completeOnboarding();
    s = await repository.getOnboardingState();
    expect(s.isCompleted, true);
  });

  test('resetOnboarding', () async {
    await repository.markStepCompleted(OnboardingStep.welcome);
    await repository.resetOnboarding();
    final s = await repository.getOnboardingState();
    expect(s.isCompleted, false);
    expect(s.completedSteps, isEmpty);
  });

  test('touchLastAppOpen aggiorna lastAppOpenDate', () async {
    await repository.touchLastAppOpen();
    final s = await repository.getOnboardingState();
    expect(s.lastAppOpenDate, isNotNull);
  });

  test('chiave singleton usa kOnboardingStateKey', () async {
    await repository.getOnboardingState();
    expect(stateBox.containsKey(kOnboardingStateKey), true);
  });
}
