import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';
import 'storage_exception.dart';

const String kProductsBoxName = 'products';

/// CRUD prodotti su [Box<Product>]. Il box deve essere già aperto.
class ProductStorageService {
  ProductStorageService(this._box);

  final Box<Product> _box;

  /// Apre il box e restituisce il servizio. Registra l'adapter se necessario.
  static Future<ProductStorageService> open() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    try {
      final box = await Hive.openBox<Product>(kProductsBoxName);
      return ProductStorageService(box);
    } catch (e, st) {
      debugPrint('ProductStorageService.open failed: $e\n$st');
      throw StorageException('Impossibile aprire il database locale', e);
    }
  }

  List<Product> getAll() {
    try {
      return _box.values.toList();
    } catch (e, st) {
      debugPrint('getAll failed: $e\n$st');
      throw StorageException('Errore lettura prodotti', e);
    }
  }

  Product? getById(String id) {
    try {
      return _box.get(id);
    } catch (e, st) {
      debugPrint('getById failed: $e\n$st');
      throw StorageException('Errore lettura prodotto', e);
    }
  }

  Future<void> upsert(Product product) async {
    try {
      await _box.put(product.id, product);
    } catch (e, st) {
      debugPrint('upsert failed: $e\n$st');
      throw StorageException('Impossibile salvare il prodotto', e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e, st) {
      debugPrint('delete failed: $e\n$st');
      throw StorageException('Impossibile eliminare il prodotto', e);
    }
  }
}
