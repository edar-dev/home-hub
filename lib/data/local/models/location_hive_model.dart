import 'package:hive/hive.dart';

part 'location_hive_model.g.dart';

@HiveType(typeId: 1)
class LocationHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? descrizione;

  @HiveField(3)
  int? updatedAtMs;

  @HiveField(4)
  int syncVersion;

  LocationHiveModel({
    required this.id,
    required this.nome,
    this.descrizione,
    this.updatedAtMs,
    this.syncVersion = 0,
  });
}
