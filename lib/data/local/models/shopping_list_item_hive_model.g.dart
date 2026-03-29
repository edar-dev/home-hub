// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListItemHiveModelAdapter
    extends TypeAdapter<ShoppingListItemHiveModel> {
  @override
  final int typeId = 6;

  @override
  ShoppingListItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListItemHiveModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      productId: fields[2] as String?,
      quantity: fields[3] as int,
      done: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListItemHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.done);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
