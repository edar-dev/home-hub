import 'package:hive/hive.dart';

part 'position_hive_model.g.dart';

@HiveType(typeId: 2)
class PositionHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descrizione;

  @HiveField(3)
  String locationId;

  @HiveField(4)
  int? updatedAtMs;

  @HiveField(5)
  int syncVersion;

  PositionHiveModel({
    required this.id,
    required this.nome,
    this.descrizione,
    required this.locationId,
    this.updatedAtMs,
    this.syncVersion = 0,
  });
}
