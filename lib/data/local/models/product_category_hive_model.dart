import 'package:hive/hive.dart';

part 'product_category_hive_model.g.dart';

@HiveType(typeId: 5)
class ProductCategoryHiveModel extends HiveObject {
  ProductCategoryHiveModel({
    required this.id,
    required this.nome,
    required this.sortOrder,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int sortOrder;
}
