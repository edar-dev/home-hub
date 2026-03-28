// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final int typeId = 0;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel(
      id: fields[0] as String,
      nome: fields[1] as String,
      dataAcquistoMs: fields[2] as int?,
      dataScadenzaMs: fields[3] as int?,
      dataAperturaMs: fields[4] as int?,
      quantitaTotale: fields[5] as int,
      quantitaRimasta: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nome)
      ..writeByte(2)
      ..write(obj.dataAcquistoMs)
      ..writeByte(3)
      ..write(obj.dataScadenzaMs)
      ..writeByte(4)
      ..write(obj.dataAperturaMs)
      ..writeByte(5)
      ..write(obj.quantitaTotale)
      ..writeByte(6)
      ..write(obj.quantitaRimasta);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
