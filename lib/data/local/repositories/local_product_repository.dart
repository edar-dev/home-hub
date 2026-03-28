import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/exceptions/product_exception.dart';
import '../../../domain/repositories/product_repository.dart';
import '../mappers/product_mapper.dart';
import '../models/product_hive_model.dart';

class LocalProductRepository implements ProductRepository {
  LocalProductRepository(this._box);

  final Box<ProductHiveModel> _box;

  @override
  Future<List<Product>> getAll() async {
    try {
      return _box.values.map(ProductMapper.toDomain).toList();
    } catch (e, st) {
      debugPrint('LocalProductRepository.getAll: $e\n$st');
      throw ProductException('Errore lettura prodotti', e);
    }
  }

  @override
  Future<Product?> getById(String id) async {
    try {
      final m = _box.get(id);
      return m == null ? null : ProductMapper.toDomain(m);
    } catch (e, st) {
      debugPrint('LocalProductRepository.getById: $e\n$st');
      throw ProductException('Errore lettura prodotto', e);
    }
  }

  @override
  Future<void> save(Product product) async {
    try {
      assert(() {
        if (kDebugMode) {
          debugPrint(
            'LocalProductRepository.save id=${product.id} nome=${product.nome}',
          );
        }
        return true;
      }());
      await _box.put(product.id, ProductMapper.toHive(product));
    } catch (e, st) {
      debugPrint('LocalProductRepository.save: $e\n$st');
      throw ProductException('Impossibile salvare il prodotto', e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (e, st) {
      debugPrint('LocalProductRepository.delete: $e\n$st');
      throw ProductException('Impossibile eliminare il prodotto', e);
    }
  }
}
