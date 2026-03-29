import '../entities/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<ShoppingList?> getActiveList();

  Future<void> saveActiveList(ShoppingList list);

  /// Sposta la lista attiva nello storico e svuota l’attiva.
  Future<void> archiveActiveList();

  Future<List<ShoppingList>> getHistory({int limit = 50});

  /// Rigenera la lista da inventario (sostituisce le voci non completate o tutta la lista).
  Future<ShoppingList> generateFromInventory({
    bool includeQtyZero = true,
    bool includeLowStock = true,
    bool includeExpiredLast7Days = true,
  });

  Future<void> toggleItemDone(String itemId, bool done);
}
