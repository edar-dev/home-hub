// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsHiveModelAdapter
    extends TypeAdapter<NotificationSettingsHiveModel> {
  @override
  final int typeId = 4;

  @override
  NotificationSettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettingsHiveModel(
      enabled: fields[0] as bool,
      remindDayBefore: fields[1] as bool,
      dailyDigest: fields[2] as bool,
      includeLowStockInDigest: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettingsHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.remindDayBefore)
      ..writeByte(2)
      ..write(obj.dailyDigest)
      ..writeByte(3)
      ..write(obj.includeLowStockInDigest);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
