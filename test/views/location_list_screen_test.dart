import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/data/local/hive_service.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
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

class _MockProductRepo extends Mock implements ProductRepository {}

class _MockHive extends Mock implements HiveService {}

class _MockLocationRepo extends Mock implements LocationRepository {}

void main() {
  setUpAll(registerHousekeepMockFallbacks);

  late _MockProductRepo mockProd;
  late _MockHive mockHive;
  late _MockLocationRepo mockLoc;

  setUp(() {
    mockProd = _MockProductRepo();
    mockHive = _MockHive();
    mockLoc = _MockLocationRepo();
    when(() => mockProd.getAll()).thenAnswer((_) async => []);
    when(() => mockProd.save(any())).thenAnswer((_) async {});
    when(() => mockProd.delete(any())).thenAnswer((_) async {});
    when(() => mockProd.getById(any())).thenAnswer((_) async => null);
    when(() => mockProd.getByPositionId(any())).thenAnswer((_) async => []);
    when(() => mockProd.getByLocationId(any())).thenAnswer((_) async => []);
    when(() => mockProd.clearPositionIdsForPositions(any()))
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
    registerFallbackValue(
      const Location(id: 'fb-l', nome: 'fb'),
    );
    registerFallbackValue(
      const StoragePosition(id: 'fb-p', nome: 'fb', locationId: 'fb-l'),
    );
    registerFallbackValue(const Location(id: 'x', nome: 'x'));
    registerFallbackValue(
      const StoragePosition(id: 'x', nome: 'x', locationId: 'x'),
    );
    registerFallbackValue(<String>[]);
  });

  Future<void> pumpShellNarrow(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 800));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      HousekeepApp(
        dependencies: AppDependencies(
          hiveService: mockHive,
          productRepository: mockProd,
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

  Future<void> openLocationManagementFromUtility(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Utilita'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gestione luoghi'));
    await tester.pumpAndSettle();
  }

  testWidgets('gestione luoghi mostra stato vuoto', (tester) async {
    await pumpShellNarrow(tester);
    await openLocationManagementFromUtility(tester);

    expect(find.text('Nessun luogo'), findsOneWidget);
  });

  testWidgets('ExpansionTile espande e mostra posizione', (tester) async {
    final loc = const Location(id: 'l1', nome: 'Cucina');
    final pos = const StoragePosition(
      id: 'p1',
      nome: 'Dispensa',
      locationId: 'l1',
    );
    when(() => mockLoc.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(location: loc, positions: [pos]),
      ],
    );

    await pumpShellNarrow(tester);
    await openLocationManagementFromUtility(tester);

    expect(find.text('Cucina'), findsWidgets);

    await tester.tap(find.text('Cucina').first);
    await tester.pumpAndSettle();

    expect(find.text('Dispensa'), findsOneWidget);
    expect(find.text('Aggiungi posizione'), findsOneWidget);
  });
}
