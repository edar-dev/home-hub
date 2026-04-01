import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/location_inventory_view_model.dart';
import 'package:housekeep/presentation/viewmodels/location_view_model.dart';
import 'package:housekeep/presentation/views/screens/location_inventory_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockProd extends Mock implements ProductRepository {}

class _MockLoc extends Mock implements LocationRepository {}

void main() {
  late _MockProd mockProd;
  late _MockLoc mockLoc;

  setUp(() {
    mockProd = _MockProd();
    mockLoc = _MockLoc();
    when(() => mockProd.getAll()).thenAnswer((_) async => []);
    when(() => mockProd.getById(any())).thenAnswer((_) async => null);
    when(() => mockProd.getByPositionId(any())).thenAnswer((_) async => []);
    when(() => mockProd.getByLocationId(any())).thenAnswer((_) async => []);
    when(() => mockProd.clearPositionIdsForPositions(any()))
        .thenAnswer((_) async {});
    when(() => mockProd.save(any())).thenAnswer((_) async {});
    when(() => mockProd.delete(any())).thenAnswer((_) async {});
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
    registerFallbackValue('');
  });

  testWidgets('mostra prodotto sotto posizione', (tester) async {
    when(() => mockLoc.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(
          location: const Location(id: 'l1', nome: 'Cucina'),
          positions: [
            const StoragePosition(
              id: 'p1',
              nome: 'Frigo',
              locationId: 'l1',
            ),
          ],
        ),
      ],
    );
    when(() => mockProd.getAll()).thenAnswer(
      (_) async => [
        Product(
          id: 'pr1',
          nome: 'Latte',
          quantitaTotale: 1,
          quantitaRimasta: 1,
          positionId: 'p1',
        ),
      ],
    );

    final locVm = LocationViewModel(mockLoc);
    await locVm.loadHierarchy();
    final invVm = LocationInventoryViewModel(mockProd, mockLoc);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mockProd),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<LocationViewModel>.value(value: locVm),
            ChangeNotifierProvider<LocationInventoryViewModel>.value(
              value: invVm,
            ),
          ],
          child: const LocationInventoryScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Riepilogo per stanza'), findsOneWidget);
    expect(find.text('Cucina'), findsWidgets);
    await tester.tap(find.text('Cucina').first);
    await tester.pumpAndSettle();
    expect(find.text('Frigo'), findsWidgets);
    expect(find.text('Latte'), findsWidgets);
  });

  testWidgets('panoramica root non mostra freccia back', (tester) async {
    final locVm = LocationViewModel(mockLoc);
    await locVm.loadHierarchy();
    final invVm = LocationInventoryViewModel(mockProd, mockLoc);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mockProd),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<LocationViewModel>.value(value: locVm),
            ChangeNotifierProvider<LocationInventoryViewModel>.value(value: invVm),
          ],
          child: const LocationInventoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('dettaglio luogo mostra freccia back', (tester) async {
    final loc = const Location(id: 'l1', nome: 'Cucina');
    when(() => mockLoc.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(location: loc, positions: const []),
      ],
    );

    final locVm = LocationViewModel(mockLoc);
    await locVm.loadHierarchy();
    final invVm = LocationInventoryViewModel(mockProd, mockLoc);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mockProd),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<LocationViewModel>.value(value: locVm),
            ChangeNotifierProvider<LocationInventoryViewModel>.value(value: invVm),
          ],
          child: const LocationInventoryScreen(locationId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('FAB crea apre quick menu', (tester) async {
    final locVm = LocationViewModel(mockLoc);
    await locVm.loadHierarchy();
    final invVm = LocationInventoryViewModel(mockProd, mockLoc);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mockProd),
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<LocationViewModel>.value(value: locVm),
            ChangeNotifierProvider<LocationInventoryViewModel>.value(value: invVm),
          ],
          child: const LocationInventoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Crea'));
    await tester.pumpAndSettle();

    expect(find.text('Nuovo luogo'), findsWidgets);
    expect(find.text('Nuovo prodotto'), findsOneWidget);
  });
}
