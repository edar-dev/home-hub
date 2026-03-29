import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/core/services/photo_storage_service.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/barcode_repository.dart';
import 'package:housekeep/domain/repositories/category_repository.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_view_model.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:housekeep/presentation/views/screens/product_form_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../support/register_mock_fallbacks.dart';
import '../support/stub_barcode_repository.dart';
import '../support/stub_category_repository.dart';

class MockFormRepository extends Mock implements ProductRepository {}

class MockFormLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockFormRepository mock;
  late MockFormLocationRepository mockLoc;

  Future<void> pumpForm(
    WidgetTester tester,
    Widget child,
  ) async {
    await tester.binding.setSurfaceSize(const Size(480, 1600));
    await tester.pumpWidget(child);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  setUpAll(() {
    registerHousekeepMockFallbacks();
    registerFallbackValue(
      Product(
        id: 'fallback',
        nome: 'x',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
    registerFallbackValue(const Location(id: 'l', nome: 'l'));
    registerFallbackValue(
      const StoragePosition(id: 'p', nome: 'p', locationId: 'l'),
    );
  });

  setUp(() {
    mock = MockFormRepository();
    mockLoc = MockFormLocationRepository();
    when(() => mock.getAll()).thenAnswer((_) async => []);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenAnswer((_) async => null);
    when(() => mock.getByPositionId(any())).thenAnswer((_) async => []);
    when(() => mock.getByLocationId(any())).thenAnswer((_) async => []);
    when(() => mock.clearPositionIdsForPositions(any())).thenAnswer((_) async {});
    when(() => mockLoc.getAllWithPositions()).thenAnswer((_) async => []);
    when(() => mockLoc.getLocationById(any())).thenAnswer((_) async => null);
    when(() => mockLoc.getLocationWithPositions(any())).thenAnswer((_) async => null);
  });

  testWidgets('form nuovo prodotto mostra campi', (tester) async {
    final viewModel = ProductViewModel(mock, mockLoc);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await pumpForm(
      tester,
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            Provider<BarcodeRepository>.value(
              value: buildStubBarcodeRepository(),
            ),
            Provider<CategoryRepository>.value(
              value: buildStubCategoryRepository(),
            ),
            Provider<PhotoStorageService>.value(value: buildTempPhotoStorage()),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );

    expect(find.text('Nuovo prodotto'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('Salva con nome vuoto mostra validazione', (tester) async {
    final viewModel = ProductViewModel(mock, mockLoc);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await pumpForm(
      tester,
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            Provider<BarcodeRepository>.value(
              value: buildStubBarcodeRepository(),
            ),
            Provider<CategoryRepository>.value(
              value: buildStubCategoryRepository(),
            ),
            Provider<PhotoStorageService>.value(value: buildTempPhotoStorage()),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.byKey(const ValueKey<String>('product-form-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Il nome è obbligatorio'), findsWidgets);
    verifyNever(() => mock.save(any()));
  });

  testWidgets('compilazione minima e Salva chiama createProduct/save', (tester) async {
    final viewModel = ProductViewModel(mock, mockLoc);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.getAll()).thenAnswer((_) async => []);

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await pumpForm(
      tester,
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            Provider<BarcodeRepository>.value(
              value: buildStubBarcodeRepository(),
            ),
            Provider<CategoryRepository>.value(
              value: buildStubCategoryRepository(),
            ),
            Provider<PhotoStorageService>.value(value: buildTempPhotoStorage()),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Pane');
    await tester.tap(find.byKey(const ValueKey<String>('product-form-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));

    verify(() => mock.save(any(that: isA<Product>()))).called(1);
  });
}
