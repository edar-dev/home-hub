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

class MockListRepository extends Mock implements ProductRepository {}

class MockListHiveService extends Mock implements HiveService {}

class MockListLocationRepository extends Mock implements LocationRepository {}

void main() {
  setUpAll(registerHousekeepMockFallbacks);

  late MockListRepository mockRepo;
  late MockListHiveService mockHive;
  late MockListLocationRepository mockLoc;

  setUp(() {
    mockRepo = MockListRepository();
    mockHive = MockListHiveService();
    mockLoc = MockListLocationRepository();
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
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
  });

  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'fallback',
        nome: 'x',
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

  Future<void> pumpListLoaded(
    WidgetTester tester, {
    Size surfaceSize = const Size(800, 600),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
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
  }

  Future<void> openInventoryTab(WidgetTester tester) async {
    final navBarTab = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Inventario'),
    );
    if (navBarTab.evaluate().isNotEmpty) {
      await tester.tap(navBarTab);
      await tester.pumpAndSettle();
      return;
    }
    final railTab = find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Inventario'),
    );
    if (railTab.evaluate().isNotEmpty) {
      await tester.tap(railTab.first);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('ricerca placeholder mostra SnackBar', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    await openInventoryTab(tester);
    await tester.tap(find.byTooltip('Cerca (prossimamente)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Ricerca'), findsWidgets);
  });

  testWidgets('lista vuota mostra messaggio', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    await openInventoryTab(tester);
    expect(find.text('Nessun prodotto'), findsOneWidget);
  });

  testWidgets('FAB apre schermata nuovo prodotto', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    await openInventoryTab(tester);

    await tester.tap(find.byKey(const ValueKey<String>('fab-product')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nuovo prodotto'), findsOneWidget);
  });

  testWidgets('mostra prodotto in lista', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'p1',
          nome: 'Farina',
          quantitaTotale: 2,
          quantitaRimasta: 1,
        ),
      ],
    );
    await pumpListLoaded(tester);
    await openInventoryTab(tester);

    expect(find.text('Farina'), findsOneWidget);
    expect(find.textContaining('Quantità: 1 / 2'), findsOneWidget);
  });

  testWidgets('tap card apre dettaglio', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'p1',
          nome: 'Riso',
          quantitaTotale: 3,
          quantitaRimasta: 2,
        ),
      ],
    );
    await pumpListLoaded(tester);
    await openInventoryTab(tester);
    await tester.tap(find.text('Riso'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Dettaglio'), findsOneWidget);
    expect(find.text('Riso'), findsWidgets);
  });

  testWidgets('swipe dismiss con conferma elimina prodotto', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'sw1',
          nome: 'SwipeMe',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      ],
    );
    when(() => mockRepo.delete('sw1')).thenAnswer((_) async {});
    await pumpListLoaded(tester);
    await openInventoryTab(tester);

    expect(find.text('SwipeMe'), findsOneWidget);
    await tester.fling(
      find.byKey(const ValueKey<String>('sw1')),
      const Offset(-500, 0),
      1200,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Eliminare il prodotto?'), findsOneWidget);
    await tester.tap(find.text('Elimina'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    verify(() => mockRepo.delete('sw1')).called(1);
  });

  testWidgets('layout wide: tap card mostra riquadro dettaglio',
      (tester) async {
    when(() => mockRepo.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'wide1',
          nome: 'Desktop',
          quantitaTotale: 2,
          quantitaRimasta: 1,
        ),
      ],
    );
    await pumpListLoaded(tester, surfaceSize: const Size(1200, 800));
    await openInventoryTab(tester);

    expect(find.text('Desktop'), findsOneWidget);
    await tester.tap(find.text('Desktop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Seleziona un prodotto dalla lista'), findsNothing);
    expect(find.text('Modifica'), findsOneWidget);
  });
}
