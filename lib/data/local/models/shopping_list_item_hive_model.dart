import 'package:hive/hive.dart';

part 'shopping_list_item_hive_model.g.dart';

@HiveType(typeId: 6)
class ShoppingListItemHiveModel {
  ShoppingListItemHiveModel({
    required this.id,
    required this.nome,
    this.productId,
    required this.quantity,
    required this.done,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  String? productId;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  bool done;
}
