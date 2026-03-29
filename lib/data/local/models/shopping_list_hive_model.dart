import 'package:hive/hive.dart';

import 'shopping_list_item_hive_model.dart';

part 'shopping_list_hive_model.g.dart';

@HiveType(typeId: 7)
class ShoppingListHiveModel extends HiveObject {
  ShoppingListHiveModel({
    required this.id,
    required this.title,
    required this.items,
    this.createdAtMs,
    this.completedAtMs,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<ShoppingListItemHiveModel> items;

  @HiveField(3)
  int? createdAtMs;

  @HiveField(4)
  int? completedAtMs;
}
