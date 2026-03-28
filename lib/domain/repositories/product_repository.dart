import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getAll();

  Future<Product?> getById(String id);

  Future<void> save(Product product);

  Future<void> delete(String id);
}
