import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/exceptions/location_exception.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_view_model.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepository mock;
  late LocationViewModel vm;

  setUpAll(() {
    registerFallbackValue(const Location(id: 'fb', nome: 'fb'));
    registerFallbackValue(
      const StoragePosition(id: 'fb', nome: 'fb', locationId: 'l'),
    );
  });

  setUp(() {
    mock = _MockLocationRepository();
    vm = LocationViewModel(mock);
  });

  test('loadHierarchy populates items', () async {
    when(() => mock.getAllWithPositions()).thenAnswer(
      (_) async => [
        const LocationWithPositions(
          location: Location(id: '1', nome: 'A'),
          positions: [],
        ),
      ],
    );
    await vm.loadHierarchy();
    expect(vm.items, hasLength(1));
    expect(vm.items.first.location.nome, 'A');
    expect(vm.errorMessage, isNull);
  });

  test('loadHierarchy maps LocationException', () async {
    when(() => mock.getAllWithPositions()).thenThrow(
      LocationException('Errore'),
    );
    await vm.loadHierarchy();
    expect(vm.items, isEmpty);
    expect(vm.errorMessage, 'Errore');
  });

  test('createLocation validation empty nome', () async {
    final err = await vm.createLocation(nome: '   ');
    expect(err, isNotNull);
    verifyNever(() => mock.saveLocation(any()));
  });

  test('createLocation success', () async {
    when(() => mock.saveLocation(any())).thenAnswer((_) async {});
    when(() => mock.getAllWithPositions()).thenAnswer((_) async => []);
    final err = await vm.createLocation(nome: 'Cucina');
    expect(err, isNull);
    verify(() => mock.saveLocation(any(that: isA<Location>()))).called(1);
  });

  test('deleteLocation', () async {
    when(() => mock.deleteLocation(any())).thenAnswer((_) async {});
    when(() => mock.getAllWithPositions()).thenAnswer((_) async => []);
    expect(await vm.deleteLocation('x'), isNull);
    verify(() => mock.deleteLocation('x')).called(1);
  });

  test('addPosition validates locationId', () async {
    final err = await vm.addPosition(locationId: '', nome: 'P');
    expect(err, isNotNull);
    verifyNever(() => mock.savePosition(any()));
  });

  test('addPosition success', () async {
    when(() => mock.savePosition(any())).thenAnswer((_) async {});
    when(() => mock.getAllWithPositions()).thenAnswer((_) async => []);
    final err = await vm.addPosition(locationId: 'l1', nome: 'Frigo');
    expect(err, isNull);
    verify(() => mock.savePosition(any(that: isA<StoragePosition>())))
        .called(1);
  });

  test('getLocationWithPositions from cache', () async {
    when(() => mock.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(
          location: const Location(id: '1', nome: 'X'),
          positions: [
            const StoragePosition(id: 'p', nome: 'Y', locationId: '1'),
          ],
        ),
      ],
    );
    await vm.loadHierarchy();
    final got = vm.getLocationWithPositions('1');
    expect(got?.positions, hasLength(1));
  });
}
