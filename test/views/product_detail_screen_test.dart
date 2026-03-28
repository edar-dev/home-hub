import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_view_model.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:housekeep/presentation/views/screens/product_detail_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockRepo extends Mock implements ProductRepository {}

class _MockLocRepo extends Mock implements LocationRepository {}

void main() {
  late _MockRepo mock;
  late _MockLocRepo mockLoc;

  setUp(() {
    mock = _MockRepo();
    mockLoc = _MockLocRepo();
    when(() => mock.getAll()).thenAnswer((_) async => []);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenAnswer((_) async => null);
    when(() => mock.getByPositionId(any())).thenAnswer((_) async => []);
    when(() => mock.getByLocationId(any())).thenAnswer((_) async => []);
    when(() => mock.clearPositionIdsForPositions(any()))
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
        id: 'fb',
        nome: 'fb',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
    registerFallbackValue(const Location(id: 'fb', nome: 'fb'));
    registerFallbackValue(
      const StoragePosition(id: 'fb', nome: 'fb', locationId: 'fb'),
    );
    registerFallbackValue(<String>[]);
  });

  testWidgets('mostra titolo e nome prodotto', (tester) async {
    final p = Product(
      id: 'd1',
      nome: 'Dett',
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    final vm = ProductViewModel(mock, mockLoc);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<ProductViewModel>.value(value: vm),
            ChangeNotifierProvider<LocationViewModel>(
              create: (_) => LocationViewModel(mockLoc),
            ),
          ],
          child: ProductDetailScreen(product: p),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dettaglio'), findsOneWidget);
    expect(find.text('Dett'), findsWidgets);
  });
}
