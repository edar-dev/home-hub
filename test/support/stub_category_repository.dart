import 'package:housekeep/domain/repositories/category_repository.dart';
import 'package:mocktail/mocktail.dart';

class StubCategoryRepository extends Mock implements CategoryRepository {}

StubCategoryRepository buildStubCategoryRepository() {
  final m = StubCategoryRepository();
  when(() => m.getAll()).thenAnswer((_) async => []);
  when(() => m.save(any())).thenAnswer((_) async {});
  when(() => m.delete(any())).thenAnswer((_) async {});
  return m;
}
