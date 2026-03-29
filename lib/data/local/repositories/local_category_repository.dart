import 'package:hive/hive.dart';

import '../../../domain/entities/product_category.dart';
import '../../../domain/repositories/category_repository.dart';
import '../../../domain/repositories/product_repository.dart';
import '../models/product_category_hive_model.dart';

class LocalCategoryRepository implements CategoryRepository {
  LocalCategoryRepository(this._box, this._products);

  final Box<ProductCategoryHiveModel> _box;
  final ProductRepository _products;

  @override
  Future<List<ProductCategory>> getAll() async {
    final list = _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list
        .map(
          (m) => ProductCategory(
            id: m.id,
            nome: m.nome,
            sortOrder: m.sortOrder,
          ),
        )
        .toList();
  }

  @override
  Future<void> save(ProductCategory category) async {
    await _box.put(
      category.id,
      ProductCategoryHiveModel(
        id: category.id,
        nome: category.nome,
        sortOrder: category.sortOrder,
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    final all = await _products.getAll();
    if (all.any((p) => p.categoryId == id)) {
      throw StateError(
        'Impossibile eliminare: ci sono prodotti che usano questa categoria.',
      );
    }
    await _box.delete(id);
  }
}
