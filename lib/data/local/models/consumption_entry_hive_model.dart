import 'package:hive/hive.dart';

class ConsumptionEntryHiveModel extends HiveObject {
  ConsumptionEntryHiveModel({
    required this.id,
    required this.productId,
    required this.amount,
    required this.unit,
    required this.dateMs,
    this.meal,
    this.recipe,
    this.notes,
    this.source = 0,
  });

  String id;
  String productId;
  double amount;
  String unit;
  int dateMs;
  int? meal;
  String? recipe;
  String? notes;
  int source;
}

class ConsumptionEntryHiveModelAdapter
    extends TypeAdapter<ConsumptionEntryHiveModel> {
  @override
  final int typeId = 10;

  @override
  ConsumptionEntryHiveModel read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ConsumptionEntryHiveModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      amount: fields[2] as double,
      unit: fields[3] as String,
      dateMs: fields[4] as int,
      meal: fields[5] as int?,
      recipe: fields[6] as String?,
      notes: fields[7] as String?,
      source: (fields[8] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ConsumptionEntryHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.dateMs)
      ..writeByte(5)
      ..write(obj.meal)
      ..writeByte(6)
      ..write(obj.recipe)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.source);
  }
}
