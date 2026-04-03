import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/exceptions/product_exception.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockProductRepository mock;
  late MockLocationRepository mockLoc;
  late ProductViewModel vm;

  setUp(() {
    mock = MockProductRepository();
    mockLoc = MockLocationRepository();
    when(() => mockLoc.getLocationWithPositions(any()))
        .thenAnswer((_) async => null);
    vm = ProductViewModel(mock, mockLoc);
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
    registerFallbackValue('');
  });

  test('setLocationFilter mostra solo prodotti nel luogo', () async {
    when(() => mockLoc.getLocationWithPositions('l1')).thenAnswer(
      (_) async => LocationWithPositions(
        location: const Location(id: 'l1', nome: 'Cucina'),
        positions: [
          const StoragePosition(id: 'pos1', nome: 'Frigo', locationId: 'l1'),
        ],
      ),
    );
    when(() => mock.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'a',
          nome: 'Latte',
          quantitaTotale: 1,
          quantitaRimasta: 1,
          positionId: 'pos1',
        ),
        Product(
          id: 'b',
          nome: 'Pane',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      ],
    );
    await vm.loadProducts();
    await vm.setLocationFilter('l1');
    expect(vm.displayedProducts, hasLength(1));
    expect(vm.displayedProducts.first.nome, 'Latte');
    await vm.setLocationFilter(null);
    expect(vm.displayedProducts, hasLength(2));
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

  test('clearError azzera errorMessage', () async {
    when(() => mock.getAll()).thenThrow(ProductException('err'));
    await vm.loadProducts();
    expect(vm.errorMessage, 'err');
    vm.clearError();
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

  test('loadProducts con lista vuota', () async {
    when(() => mock.getAll()).thenAnswer((_) async => []);
    await vm.loadProducts();
    expect(vm.products, isEmpty);
    expect(vm.errorMessage, isNull);
  });

  test('loadProducts imposta isLoading true fino al completamento', () async {
    final completer = Completer<List<Product>>();
    when(() => mock.getAll()).thenAnswer((_) => completer.future);
    final future = vm.loadProducts();
    expect(vm.isLoading, isTrue);
    completer.complete([]);
    await future;
    expect(vm.isLoading, isFalse);
  });

  test('updateProduct chiama save quando valido', () async {
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.getAll()).thenAnswer((_) async => []);
    final ok = Product(
      id: '1',
      nome: 'Nuovo',
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    expect(await vm.updateProduct(ok), isNull);
    verify(() => mock.save(any())).called(1);
  });

  test('updateProduct non chiama save se non valido', () async {
    when(() => mock.getAll()).thenAnswer((_) async => []);
    final bad = Product(
      id: '2',
      nome: '',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    expect(await vm.updateProduct(bad), isNotNull);
    verifyNever(() => mock.save(any()));
  });

  test('updateProduct mappa ProductException', () async {
    when(() => mock.save(any()))
        .thenThrow(ProductException('Salvataggio fallito'));
    final p = Product(
      id: '1',
      nome: 'X',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    expect(await vm.updateProduct(p), 'Salvataggio fallito');
    expect(vm.errorMessage, 'Salvataggio fallito');
  });

  test('deleteProduct successo ed errore', () async {
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getAll()).thenAnswer((_) async => []);
    expect(await vm.deleteProduct('a'), isNull);
    verify(() => mock.delete('a')).called(1);

    when(() => mock.delete(any())).thenThrow(ProductException('No delete'));
    expect(await vm.deleteProduct('b'), 'No delete');
  });

  test('loadProducts errore generico', () async {
    when(() => mock.getAll()).thenThrow(Exception('boom'));
    await vm.loadProducts();
    expect(vm.errorMessage, isNotNull);
    expect(vm.products, isEmpty);
  });

  test('createProduct errore generico', () async {
    when(() => mock.save(any())).thenThrow(Exception('boom'));
    when(() => mock.getAll()).thenAnswer((_) async => []);
    final p = Product(
      id: '1',
      nome: 'X',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    expect(await vm.createProduct(p), isNotNull);
  });

  test('updateProduct errore generico', () async {
    when(() => mock.save(any())).thenThrow(Exception('boom'));
    final p = Product(
      id: '1',
      nome: 'X',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    expect(await vm.updateProduct(p), isNotNull);
  });

  test('deleteProduct errore generico', () async {
    when(() => mock.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'z',
          nome: 'Z',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      ],
    );
    await vm.loadProducts();
    when(() => mock.delete(any())).thenThrow(Exception('boom'));
    expect(await vm.deleteProduct('z'), isNotNull);
  });
}
