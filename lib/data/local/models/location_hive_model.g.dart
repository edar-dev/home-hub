// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocationHiveModelAdapter extends TypeAdapter<LocationHiveModel> {
  @override
  final int typeId = 1;

  @override
  LocationHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationHiveModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      descrizione: fields[2] as String?,
      updatedAtMs: fields[3] as int?,
      syncVersion: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocationHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.descrizione)
      ..writeByte(3)
      ..write(obj.updatedAtMs)
      ..writeByte(4)
      ..write(obj.syncVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
