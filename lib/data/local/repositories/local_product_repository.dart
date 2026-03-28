import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/exceptions/product_exception.dart';
import '../../../domain/repositories/product_repository.dart';
import '../mappers/product_mapper.dart';
import '../models/position_hive_model.dart';
import '../models/product_hive_model.dart';

class LocalProductRepository implements ProductRepository {
  LocalProductRepository(this._box, this._positionsBox);

  final Box<ProductHiveModel> _box;
  final Box<PositionHiveModel> _positionsBox;

  void _validatePositionRef(Product product) {
    final pid = product.positionId;
    if (pid != null && !_positionsBox.containsKey(pid)) {
      throw ProductException('La posizione selezionata non esiste');
    }
  }

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
      _validatePositionRef(product);
      assert(() {
        if (kDebugMode) {
          debugPrint(
            'LocalProductRepository.save id=${product.id} nome=${product.nome}',
          );
        }
        return true;
      }());
      await _box.put(product.id, ProductMapper.toHive(product));
    } on ProductException {
      rethrow;
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

  @override
  Future<List<Product>> getByPositionId(String positionId) async {
    try {
      final list = _box.values
          .map(ProductMapper.toDomain)
          .where((p) => p.positionId == positionId)
          .toList()
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      return list;
    } catch (e, st) {
      debugPrint('LocalProductRepository.getByPositionId: $e\n$st');
      throw ProductException('Errore lettura prodotti per posizione', e);
    }
  }

  @override
  Future<List<Product>> getByLocationId(String locationId) async {
    try {
      final positionIds = <String>{};
      for (final pos in _positionsBox.values) {
        if (pos.locationId == locationId) {
          positionIds.add(pos.id);
        }
      }
      final list = _box.values
          .map(ProductMapper.toDomain)
          .where(
            (p) =>
                p.positionId != null && positionIds.contains(p.positionId),
          )
          .toList()
        ..sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
      return list;
    } catch (e, st) {
      debugPrint('LocalProductRepository.getByLocationId: $e\n$st');
      throw ProductException('Errore lettura prodotti per luogo', e);
    }
  }

  @override
  Future<void> clearPositionIdsForPositions(
    Iterable<String> positionIds,
  ) async {
    try {
      final set = positionIds.toSet();
      if (set.isEmpty) return;
      for (final key in _box.keys.toList()) {
        final m = _box.get(key);
        if (m == null) continue;
        final pid = m.positionId;
        if (pid != null && set.contains(pid)) {
          final p = ProductMapper.toDomain(m).copyWith(clearPositionId: true);
          await _box.put(key, ProductMapper.toHive(p));
        }
      }
    } catch (e, st) {
      debugPrint('LocalProductRepository.clearPositionIdsForPositions: $e\n$st');
      throw ProductException('Impossibile aggiornare i prodotti collegati', e);
    }
  }
}
