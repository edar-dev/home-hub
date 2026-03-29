// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListHiveModelAdapter extends TypeAdapter<ShoppingListHiveModel> {
  @override
  final int typeId = 7;

  @override
  ShoppingListHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      items: (fields[2] as List).cast<ShoppingListItemHiveModel>(),
      createdAtMs: fields[3] as int?,
      completedAtMs: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.createdAtMs)
      ..writeByte(4)
      ..write(obj.completedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
