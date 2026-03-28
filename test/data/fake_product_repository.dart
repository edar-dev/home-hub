import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';

/// Repository in-memory per test veloci senza I/O Hive.
class FakeProductRepository implements ProductRepository {
  final Map<String, Product> _byId = {};

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
}
