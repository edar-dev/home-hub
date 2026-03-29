// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductCategoryHiveModelAdapter
    extends TypeAdapter<ProductCategoryHiveModel> {
  @override
  final int typeId = 5;

  @override
  ProductCategoryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductCategoryHiveModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      sortOrder: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProductCategoryHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategoryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
