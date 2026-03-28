import 'package:hive/hive.dart';

part 'product_hive_model.g.dart';

/// DTO Hive — stesso `typeId` e `@HiveField` del modello legacy per compatibilità box `products`.
@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int? dataAcquistoMs;

  @HiveField(3)
  int? dataScadenzaMs;

  @HiveField(4)
  int? dataAperturaMs;

  @HiveField(5)
  int quantitaTotale;

  @HiveField(6)
  int quantitaRimasta;

  @HiveField(7)
  String? positionId;

  ProductHiveModel({
    required this.id,
    required this.nome,
    this.dataAcquistoMs,
    this.dataScadenzaMs,
    this.dataAperturaMs,
    required this.quantitaTotale,
    required this.quantitaRimasta,
    this.positionId,
  });
}
