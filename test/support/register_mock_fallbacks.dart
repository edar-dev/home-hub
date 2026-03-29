import 'package:housekeep/domain/entities/product_category.dart';
import 'package:housekeep/domain/entities/shopping_list.dart';
import 'package:mocktail/mocktail.dart';

/// Registrazioni mocktail per stub repository (save/get con [any]).
void registerHousekeepMockFallbacks() {
  registerFallbackValue(
    const ProductCategory(id: 'fb-cat', nome: 'fb'),
  );
  registerFallbackValue(
    ShoppingList(
      id: 'fb-sl',
      title: 't',
      items: const [],
      createdAt: DateTime.utc(2026),
    ),
  );
}
