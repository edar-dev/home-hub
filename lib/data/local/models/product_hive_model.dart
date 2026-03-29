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

  @HiveField(8)
  int? updatedAtMs;

  @HiveField(9)
  int syncVersion;

  @HiveField(10)
  String? barcode;

  @HiveField(11)
  String? imageRelativePath;

  @HiveField(12)
  String? categoryId;

  ProductHiveModel({
    required this.id,
    required this.nome,
    this.dataAcquistoMs,
    this.dataScadenzaMs,
    this.dataAperturaMs,
    required this.quantitaTotale,
    required this.quantitaRimasta,
    this.positionId,
    this.updatedAtMs,
    this.syncVersion = 0,
    this.barcode,
    this.imageRelativePath,
    this.categoryId,
  });
}
