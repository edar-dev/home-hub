import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/data/local/hive_service.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHive extends Mock implements HiveService {}

class _MockRepo extends Mock implements ProductRepository {}

class _MockLocationRepo extends Mock implements LocationRepository {}

void main() {
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
    registerFallbackValue(const Location(id: 'x', nome: 'x'));
    registerFallbackValue(
      const StoragePosition(id: 'x', nome: 'x', locationId: 'x'),
    );
    registerFallbackValue(<String>[]);
  });

  testWidgets('HousekeepApp si costruisce', (tester) async {
    final mockHive = _MockHive();
    final mockRepo = _MockRepo();
    final mockLoc = _MockLocationRepo();
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockRepo.getByPositionId(any())).thenAnswer((_) async => []);
    when(() => mockRepo.getByLocationId(any())).thenAnswer((_) async => []);
    when(() => mockRepo.clearPositionIdsForPositions(any()))
        .thenAnswer((_) async {});
    when(() => mockLoc.getAllWithPositions()).thenAnswer((_) async => []);
    when(() => mockLoc.getLocationById(any())).thenAnswer((_) async => null);
    when(() => mockLoc.getLocationWithPositions(any()))
        .thenAnswer((_) async => null);
    when(() => mockLoc.saveLocation(any())).thenAnswer((_) async {});
    when(() => mockLoc.deleteLocation(any())).thenAnswer((_) async {});
    when(() => mockLoc.savePosition(any())).thenAnswer((_) async {});
    when(() => mockLoc.deletePosition(any())).thenAnswer((_) async {});
    await tester.pumpWidget(
      HousekeepApp(
        dependencies: AppDependencies(
          hiveService: mockHive,
          productRepository: mockRepo,
          locationRepository: mockLoc,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inventario'), findsWidgets);
  });
}
