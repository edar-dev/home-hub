// Baseline performance (Flutter test VM, debug build — valori indicativi).
//
// Come usare per confronti reali: `flutter test test/performance/product_list_scale_benchmark_test.dart`
// e, per misure frame accurate, Flutter DevTools Performance su device/profile con stesso seed.
//
// Soglie sotto sono empiriche anti-regressione in CI (molto larghe per macchine lente).
//
// | Righe | pump iniziale | fling+settle (target empirico) |
// |-------|-----------------|--------------------------------|
// | 1000  | < 5s            | < 5s                           |
// | 5000  | < 25s           | < 10s                          |
// | 10000 | < 45s           | < 15s                          |

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

import '../support/stub_analytics_repository.dart';
import 'package:housekeep/data/local/repositories/no_op_notification_repository.dart';

import '../support/stub_barcode_repository.dart';
import '../support/stub_category_repository.dart';
import '../support/stub_onboarding_repository.dart';
import '../support/stub_shopping_list_repository.dart';
import '../support/register_mock_fallbacks.dart';

class _MockHive extends Mock implements HiveService {}

class _LargeListRepo extends Mock implements ProductRepository {}

class _MockLocationRepo extends Mock implements LocationRepository {}

Future<void> _runScale(
  WidgetTester tester, {
  required int count,
  required Duration maxPump,
  required Duration maxScroll,
}) async {
  final products = List<Product>.generate(
    count,
    (i) => Product(
      id: 'p$i',
      nome: 'Prodotto ${i.toString().padLeft(5, '0')}',
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

  final pumpSw = Stopwatch()..start();
  await tester.pumpWidget(
    HousekeepApp(
      dependencies: AppDependencies(
        hiveService: mockHive,
        productRepository: mockRepo,
        locationRepository: mockLoc,
        analyticsRepository: buildStubAnalyticsRepository(),
        barcodeRepository: buildStubBarcodeRepository(),
        photoStorage: buildTempPhotoStorage(),
        notificationRepository: NoOpNotificationRepository(),
        categoryRepository: buildStubCategoryRepository(),
        shoppingListRepository: buildStubShoppingListRepository(),
        onboardingRepository: buildStubOnboardingRepository(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(find.text('Inventario'));
  await tester.pumpAndSettle();
  pumpSw.stop();

  expect(find.text('Prodotto 00000'), findsOneWidget);

  final scrollSw = Stopwatch()..start();
  await tester.fling(find.byType(ListView), const Offset(0, -4000), 10000);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  scrollSw.stop();

  expect(pumpSw.elapsed, lessThan(maxPump));
  expect(scrollSw.elapsed, lessThan(maxScroll));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerHousekeepMockFallbacks();
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

  testWidgets('scala 1000: pump e scroll', (tester) async {
    await _runScale(
      tester,
      count: 1000,
      maxPump: const Duration(seconds: 5),
      maxScroll: const Duration(seconds: 5),
    );
  });

  testWidgets('scala 5000: pump e scroll', (tester) async {
    await _runScale(
      tester,
      count: 5000,
      maxPump: const Duration(seconds: 25),
      maxScroll: const Duration(seconds: 10),
    );
  });

  testWidgets('scala 10000: pump e scroll', (tester) async {
    await _runScale(
      tester,
      count: 10000,
      maxPump: const Duration(seconds: 45),
      maxScroll: const Duration(seconds: 15),
    );
  });
}
