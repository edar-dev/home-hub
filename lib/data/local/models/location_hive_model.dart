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

  LocationHiveModel({
    required this.id,
    required this.nome,
    this.descrizione,
  });
}
