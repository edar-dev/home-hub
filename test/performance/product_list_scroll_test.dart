import 'package:flutter/material.dart';
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

class _LargeListRepo extends Mock implements ProductRepository {}

class _MockLocationRepo extends Mock implements LocationRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('lista 1000 prodotti: pump e scroll entro soglia empirica', (tester) async {
    final products = List<Product>.generate(
      1000,
      (i) => Product(
        id: 'p$i',
        nome: 'Prodotto ${i.toString().padLeft(4, '0')}',
        quantitaTotale: 2,
        quantitaRimasta: 1,
      ),
    );

    final mockRepo = _LargeListRepo();
    final mockHive = _MockHive();
    final mockLoc = _MockLocationRepo();
    when(() => mockRepo.getAll()).thenAnswer((_) async => products);
    when(() => mockRepo.save(any())).thenAnswer((_) async {});
    when(() => mockRepo.delete(any())).thenAnswer((_) async {});
    when(() => mockRepo.getById(any())).thenAnswer((_) async => null);
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

    final sw = Stopwatch()..start();
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
    sw.stop();

    expect(find.text('Prodotto 0000'), findsOneWidget);

    final scrollSw = Stopwatch()..start();
    await tester.fling(find.byType(ListView), const Offset(0, -2000), 8000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    scrollSw.stop();

    // In debug/VM la soglia varia; in CI può essere più lenta. Obiettivo: non regressione grossolana.
    expect(sw.elapsed, lessThan(const Duration(seconds: 5)));
    expect(scrollSw.elapsed, lessThan(const Duration(seconds: 5)));
  });
}
