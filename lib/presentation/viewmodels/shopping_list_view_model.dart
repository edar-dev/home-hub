import 'package:flutter/foundation.dart';

import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/shopping_list_repository.dart';

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel(this._shopping) {
    load();
  }

  final ShoppingListRepository _shopping;

  ShoppingList? _list;
  bool _loading = true;
  String? _errorMessage;

  ShoppingList? get list => _list;

  bool get isLoading => _loading;

  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _list = await _shopping.getActiveList();
    } catch (e, st) {
      debugPrint('ShoppingListViewModel.load: $e\n$st');
      _errorMessage = 'Impossibile caricare la lista.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> generate() async {
    try {
      _list = await _shopping.generateFromInventory();
      _errorMessage = null;
      notifyListeners();
    } catch (e, st) {
      debugPrint('ShoppingListViewModel.generate: $e\n$st');
      _errorMessage = 'Impossibile generare la lista.';
      notifyListeners();
    }
  }

  Future<void> toggleItem(String itemId, bool done) async {
    try {
      await _shopping.toggleItemDone(itemId, done);
      await load();
    } catch (e, st) {
      debugPrint('ShoppingListViewModel.toggleItem: $e\n$st');
      _errorMessage = 'Aggiornamento voce fallito.';
      notifyListeners();
    }
  }

  Future<void> archive() async {
    try {
      await _shopping.archiveActiveList();
      await load();
    } catch (e, st) {
      debugPrint('ShoppingListViewModel.archive: $e\n$st');
      _errorMessage = 'Archiviazione fallita.';
      notifyListeners();
    }
  }
}
