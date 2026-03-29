import 'package:housekeep/domain/entities/shopping_list.dart';
import 'package:housekeep/domain/repositories/shopping_list_repository.dart';
import 'package:mocktail/mocktail.dart';

class StubShoppingListRepository extends Mock implements ShoppingListRepository {}

StubShoppingListRepository buildStubShoppingListRepository() {
  final m = StubShoppingListRepository();
  when(() => m.getActiveList()).thenAnswer((_) async => null);
  when(() => m.saveActiveList(any())).thenAnswer((_) async {});
  when(() => m.archiveActiveList()).thenAnswer((_) async {});
  when(() => m.getHistory(limit: any(named: 'limit'))).thenAnswer((_) async => []);
  when(
    () => m.generateFromInventory(
      includeQtyZero: any(named: 'includeQtyZero'),
      includeLowStock: any(named: 'includeLowStock'),
      includeExpiredLast7Days: any(named: 'includeExpiredLast7Days'),
    ),
  ).thenAnswer(
    (_) async => ShoppingList(
      id: 'stub',
      title: 'Lista',
      items: const [],
      createdAt: DateTime.now(),
    ),
  );
  when(
    () => m.toggleItemDone(any(), any()),
  ).thenAnswer((_) async {});
  return m;
}
