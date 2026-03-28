import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();

  Future<Product?> getById(String id);

  Future<void> save(Product product);

  Future<void> delete(String id);

  /// Prodotti assegnati a una [StoragePosition] (FASE 3).
  Future<List<Product>> getByPositionId(String positionId);

  /// Prodotti le cui posizioni appartengono alla [Location] indicata.
  Future<List<Product>> getByLocationId(String locationId);

  /// Rimuove `positionId` dai prodotti che puntano a una delle posizioni date.
  Future<void> clearPositionIdsForPositions(Iterable<String> positionIds);
}
