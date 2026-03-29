// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_settings_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnboardingSettingsHiveModelAdapter
    extends TypeAdapter<OnboardingSettingsHiveModel> {
  @override
  final int typeId = 9;

  @override
  OnboardingSettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingSettingsHiveModel(
      skipOnboardingAutomatically: fields[0] as bool,
      showOnboardingOnUpdate: fields[1] as bool,
      animationSpeedIndex: fields[2] as int,
      preferredLanguageIndex: fields[3] as int,
      enableAnalytics: fields[4] as bool,
      showContextualHelp: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingSettingsHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.skipOnboardingAutomatically)
      ..writeByte(1)
      ..write(obj.showOnboardingOnUpdate)
      ..writeByte(2)
      ..write(obj.animationSpeedIndex)
      ..writeByte(3)
      ..write(obj.preferredLanguageIndex)
      ..writeByte(4)
      ..write(obj.enableAnalytics)
      ..writeByte(5)
      ..write(obj.showContextualHelp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingSettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
