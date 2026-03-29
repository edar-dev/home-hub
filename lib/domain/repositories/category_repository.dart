import '../entities/product_category.dart';

abstract class CategoryRepository {
  Future<List<ProductCategory>> getAll();

  Future<void> save(ProductCategory category);

  Future<void> delete(String id);
}
