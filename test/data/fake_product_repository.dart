import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';

/// Repository in-memory per test veloci senza I/O Hive.
class FakeProductRepository implements ProductRepository {
  final Map<String, Product> _byId = {};

  /// Solo test: mappa posizione → luogo per [getByLocationId].
  final Map<String, Set<String>> _positionIdsByLocation = {};

  void testBindPositionToLocation(String positionId, String locationId) {
    (_positionIdsByLocation[locationId] ??= {}).add(positionId);
  }

  @override
  Future<void> delete(String id) async {
    _byId.remove(id);
  }

  @override
  Future<List<Product>> getAll() async {
    return _byId.values.toList();
  }

  @override
  Future<Product?> getById(String id) async {
    return _byId[id];
  }

  @override
  Future<void> save(Product product) async {
    _byId[product.id] = product;
  }

  @override
  Future<List<Product>> getByPositionId(String positionId) async {
    return _byId.values.where((p) => p.positionId == positionId).toList();
  }

  @override
  Future<List<Product>> getByLocationId(String locationId) async {
    final ids = _positionIdsByLocation[locationId] ?? {};
    return _byId.values
        .where((p) => p.positionId != null && ids.contains(p.positionId))
        .toList();
  }

  @override
  Future<void> clearPositionIdsForPositions(
    Iterable<String> positionIds,
  ) async {
    final set = positionIds.toSet();
    if (set.isEmpty) return;
    for (final entry in _byId.entries.toList()) {
      final pid = entry.value.positionId;
      if (pid != null && set.contains(pid)) {
        _byId[entry.key] = entry.value.copyWith(clearPositionId: true);
      }
    }
  }
}
