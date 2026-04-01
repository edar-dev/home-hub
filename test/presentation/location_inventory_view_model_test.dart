import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_inventory_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductRepo extends Mock implements ProductRepository {}

class _MockLocationRepo extends Mock implements LocationRepository {}

void main() {
  late _MockProductRepo productRepo;
  late _MockLocationRepo locationRepo;

  setUpAll(() {
    registerFallbackValue(
      Product(id: 'fb', nome: 'fb', quantitaTotale: 1, quantitaRimasta: 1),
    );
    registerFallbackValue(const Location(id: 'fb', nome: 'fb'));
    registerFallbackValue(
      const StoragePosition(id: 'fb', nome: 'fb', locationId: 'fb'),
    );
    registerFallbackValue('');
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    productRepo = _MockProductRepo();
    locationRepo = _MockLocationRepo();
    when(() => locationRepo.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(
          location: const Location(id: 'l1', nome: 'Cucina'),
          positions: const [
            StoragePosition(id: 'p1', nome: 'Dispensa', locationId: 'l1'),
          ],
        ),
      ],
    );
    when(() => productRepo.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'a',
          nome: 'Pasta',
          quantitaTotale: 3,
          quantitaRimasta: 1,
          positionId: 'p1',
          dataScadenza: DateTime.now().add(const Duration(days: 2)),
        ),
        Product(
          id: 'b',
          nome: 'Biscotti',
          quantitaTotale: 2,
          quantitaRimasta: 2,
          positionId: 'p1',
        ),
      ],
    );
  });

  test('filtra per testo e stato apertura', () async {
    final vm = LocationInventoryViewModel(productRepo, locationRepo);
    await vm.load();
    expect(vm.sections.first.blocks.first.products.length, 2);

    vm.setSearchQuery('pas');
    expect(vm.sections.first.blocks.first.products.length, 1);
    expect(vm.sections.first.blocks.first.products.first.nome, 'Pasta');

    vm.setOpenStateFilter(ProductOpenStateFilter.unopened);
    expect(vm.sections.first.blocks.first.products.length, 1);
    expect(vm.sections.first.blocks.first.products.first.nome, 'Pasta');
  });

  test('filtra per stato prodotto e reset', () async {
    final vm = LocationInventoryViewModel(productRepo, locationRepo);
    await vm.load();

    vm.setStatusFilter(ProductStatusFilter.lowStock);
    expect(vm.sections.first.blocks.first.products.length, 1);
    expect(vm.sections.first.blocks.first.products.first.nome, 'Pasta');

    vm.clearProductFilters();
    expect(vm.sections.first.blocks.first.products.length, 2);
  });
}
