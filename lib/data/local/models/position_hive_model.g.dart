// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PositionHiveModelAdapter extends TypeAdapter<PositionHiveModel> {
  @override
  final int typeId = 2;

  @override
  PositionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PositionHiveModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      descrizione: fields[2] as String?,
      locationId: fields[3] as String,
      updatedAtMs: fields[4] as int?,
      syncVersion: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PositionHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descrizione)
      ..writeByte(3)
      ..write(obj.locationId)
      ..writeByte(4)
      ..write(obj.updatedAtMs)
      ..writeByte(5)
      ..write(obj.syncVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
