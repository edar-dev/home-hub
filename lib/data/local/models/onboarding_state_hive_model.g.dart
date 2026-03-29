// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnboardingStateHiveModelAdapter
    extends TypeAdapter<OnboardingStateHiveModel> {
  @override
  final int typeId = 8;

  @override
  OnboardingStateHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingStateHiveModel(
      isCompleted: fields[0] as bool,
      currentStepIndex: fields[1] as int?,
      firstCompletedAtMs: fields[2] as int?,
      lastViewedAtMs: fields[3] as int?,
      completedStepIndices: (fields[4] as List).cast<int>(),
      showAnimations: fields[5] as bool,
      animationSpeedIndex: fields[6] as int,
      languageIndex: fields[7] as int,
      showContextualTooltips: fields[8] as bool,
      lastAppOpenAtMs: fields[9] as int?,
      lastPromptedFeatureEpoch: fields[10] as int,
      tourResumeStepIndex: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingStateHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.isCompleted)
      ..writeByte(1)
      ..write(obj.currentStepIndex)
      ..writeByte(2)
      ..write(obj.firstCompletedAtMs)
      ..writeByte(3)
      ..write(obj.lastViewedAtMs)
      ..writeByte(4)
      ..write(obj.completedStepIndices)
      ..writeByte(5)
      ..write(obj.showAnimations)
      ..writeByte(6)
      ..write(obj.animationSpeedIndex)
      ..writeByte(7)
      ..write(obj.languageIndex)
      ..writeByte(8)
      ..write(obj.showContextualTooltips)
      ..writeByte(9)
      ..write(obj.lastAppOpenAtMs)
      ..writeByte(10)
      ..write(obj.lastPromptedFeatureEpoch)
      ..writeByte(11)
      ..write(obj.tourResumeStepIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStateHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
