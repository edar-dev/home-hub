/// Voce lista spesa.
class ShoppingListItem {
  const ShoppingListItem({
    required this.id,
    required this.nome,
    this.productId,
    this.quantity = 1,
    this.done = false,
  });

  final String id;
  final String nome;
  final String? productId;
  final int quantity;
  final bool done;

  ShoppingListItem copyWith({
    String? id,
    String? nome,
    String? productId,
    int? quantity,
    bool? done,
    bool clearProductId = false,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      productId: clearProductId ? null : (productId ?? this.productId),
      quantity: quantity ?? this.quantity,
      done: done ?? this.done,
    );
  }
}
