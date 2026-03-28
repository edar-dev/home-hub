import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_view_model.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:housekeep/presentation/views/screens/product_form_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFormRepository extends Mock implements ProductRepository {}

class MockFormLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockFormRepository mock;
  late MockFormLocationRepository mockLoc;

  setUpAll(() {
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
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nuovo prodotto'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('Salva con nome vuoto mostra validazione', (tester) async {
    final viewModel = ProductViewModel(mock, mockLoc);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Aggiungi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Il nome è obbligatorio'), findsWidgets);
    verifyNever(() => mock.save(any()));
  });

  testWidgets('compilazione minima e Salva chiama createProduct/save', (tester) async {
    final viewModel = ProductViewModel(mock, mockLoc);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.getAll()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: const ProductFormScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextFormField).first, 'Pane');
    await tester.tap(find.text('Aggiungi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));

    verify(() => mock.save(any(that: isA<Product>()))).called(1);
  });
}
