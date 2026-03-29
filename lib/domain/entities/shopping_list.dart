import 'shopping_list_item.dart';

/// Lista spesa attiva o archiviata.
class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.title,
    required this.items,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final String title;
  final List<ShoppingListItem> items;
  final DateTime? createdAt;
  final DateTime? completedAt;

  bool get isArchived => completedAt != null;
}
