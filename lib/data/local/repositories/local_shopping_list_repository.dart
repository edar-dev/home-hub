import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/shopping_list.dart';
import '../../../domain/entities/shopping_list_item.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/shopping_list_repository.dart';
import '../models/shopping_list_hive_model.dart';
import '../models/shopping_list_item_hive_model.dart';

class LocalShoppingListRepository implements ShoppingListRepository {
  LocalShoppingListRepository(
    this._activeBox,
    this._historyBox,
    this._products,
  );

  static const String _activeKey = 'list';

  final Box<ShoppingListHiveModel> _activeBox;
  final Box<ShoppingListHiveModel> _historyBox;
  final ProductRepository _products;

  ShoppingListItem _itemFromHive(ShoppingListItemHiveModel m) {
    return ShoppingListItem(
      id: m.id,
      nome: m.nome,
      productId: m.productId,
      quantity: m.quantity,
      done: m.done,
    );
  }

  ShoppingListItemHiveModel _itemToHive(ShoppingListItem i) {
    return ShoppingListItemHiveModel(
      id: i.id,
      nome: i.nome,
      productId: i.productId,
      quantity: i.quantity,
      done: i.done,
    );
  }

  ShoppingList _listFromHive(ShoppingListHiveModel m) {
    return ShoppingList(
      id: m.id,
      title: m.title,
      items: m.items.map(_itemFromHive).toList(),
      createdAt: m.createdAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.createdAtMs!),
      completedAt: m.completedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.completedAtMs!),
    );
  }

  ShoppingListHiveModel _listToHive(ShoppingList list) {
    return ShoppingListHiveModel(
      id: list.id,
      title: list.title,
      items: list.items.map(_itemToHive).toList(),
      createdAtMs: list.createdAt?.millisecondsSinceEpoch,
      completedAtMs: list.completedAt?.millisecondsSinceEpoch,
    );
  }

  @override
  Future<ShoppingList?> getActiveList() async {
    final m = _activeBox.get(_activeKey);
    if (m == null) return null;
    return _listFromHive(m);
  }

  @override
  Future<void> saveActiveList(ShoppingList list) async {
    await _activeBox.put(_activeKey, _listToHive(list));
  }

  @override
  Future<void> archiveActiveList() async {
    final m = _activeBox.get(_activeKey);
    if (m == null) return;
    final domain = _listFromHive(m);
    final archived = ShoppingList(
      id: domain.id,
      title: domain.title,
      items: domain.items,
      createdAt: domain.createdAt,
      completedAt: DateTime.now(),
    );
    await _historyBox.put(archived.id, _listToHive(archived));
    await _activeBox.delete(_activeKey);
  }

  @override
  Future<List<ShoppingList>> getHistory({int limit = 50}) async {
    final list = _historyBox.values.map(_listFromHive).toList()
      ..sort(
        (a, b) => (b.completedAt?.millisecondsSinceEpoch ?? 0)
            .compareTo(a.completedAt?.millisecondsSinceEpoch ?? 0),
      );
    if (list.length <= limit) return list;
    return list.take(limit).toList();
  }

  @override
  Future<ShoppingList> generateFromInventory({
    bool includeQtyZero = true,
    bool includeLowStock = true,
    bool includeExpiredLast7Days = true,
  }) async {
    final all = await _products.getAll();
    final seen = <String>{};
    final items = <ShoppingListItem>[];
    for (final p in all) {
      var take = false;
      if (includeQtyZero && p.quantitaRimasta == 0) {
        take = true;
      }
      if (includeLowStock && p.isLowStock && p.quantitaRimasta > 0) {
        take = true;
      }
      if (includeExpiredLast7Days && p.isExpired) {
        final d = p.daysUntilExpiry;
        if (d != null && d >= -7 && d <= 0) {
          take = true;
        }
      }
      if (!take || seen.contains(p.id)) continue;
      seen.add(p.id);
      items.add(
        ShoppingListItem(
          id: const Uuid().v4(),
          nome: p.nome,
          productId: p.id,
          quantity: 1,
        ),
      );
    }
    final list = ShoppingList(
      id: const Uuid().v4(),
      title: 'Lista spesa',
      items: items,
      createdAt: DateTime.now(),
    );
    await saveActiveList(list);
    return list;
  }

  @override
  Future<void> toggleItemDone(String itemId, bool done) async {
    final current = await getActiveList();
    if (current == null) return;
    final items = current.items
        .map(
          (e) => e.id == itemId ? e.copyWith(done: done) : e,
        )
        .toList();
    await saveActiveList(
      ShoppingList(
        id: current.id,
        title: current.title,
        items: items,
        createdAt: current.createdAt,
        completedAt: current.completedAt,
      ),
    );
  }
}
