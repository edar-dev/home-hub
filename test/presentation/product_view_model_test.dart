import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/exceptions/product_exception.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mock;
  late ProductViewModel vm;

  setUp(() {
    mock = MockProductRepository();
    vm = ProductViewModel(mock);
  });

  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'fb',
        nome: 'fb',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
  });

  test('loadProducts sorts by nome', () async {
    when(() => mock.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: '2',
          nome: 'Banana',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
        Product(
          id: '1',
          nome: 'Albicocca',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      ],
    );
    await vm.loadProducts();
    expect(vm.products.first.nome, 'Albicocca');
    expect(vm.products.last.nome, 'Banana');
    expect(vm.errorMessage, isNull);
  });

  test('loadProducts maps ProductException to message', () async {
    when(() => mock.getAll()).thenThrow(
      ProductException('Errore lettura'),
    );
    await vm.loadProducts();
    expect(vm.products, isEmpty);
    expect(vm.errorMessage, 'Errore lettura');
  });

  test('createProduct returns validation message when invalid', () async {
    final bad = Product(
      id: '1',
      nome: '',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    final err = await vm.createProduct(bad);
    expect(err, isNotNull);
    verifyNever(() => mock.save(any()));
  });

  test('createProduct calls save when valid', () async {
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.getAll()).thenAnswer((_) async => []);
    final p = Product(
      id: '1',
      nome: 'Ok',
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    final err = await vm.createProduct(p);
    expect(err, isNull);
    verify(() => mock.save(any(that: isA<Product>()))).called(1);
  });
}
