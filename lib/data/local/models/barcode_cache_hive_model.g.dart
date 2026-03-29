// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barcode_cache_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BarcodeCacheHiveModelAdapter extends TypeAdapter<BarcodeCacheHiveModel> {
  @override
  final int typeId = 3;

  @override
  BarcodeCacheHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BarcodeCacheHiveModel(
      barcode: fields[0] as String,
      suggestedName: fields[1] as String?,
      scanCount: fields[2] as int,
      lastScannedMs: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BarcodeCacheHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.suggestedName)
      ..writeByte(2)
      ..write(obj.scanCount)
      ..writeByte(3)
      ..write(obj.lastScannedMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeCacheHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
