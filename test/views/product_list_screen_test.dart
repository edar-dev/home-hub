import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/data/local/hive_service.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ProductRepository {}

class MockListHiveService extends Mock implements HiveService {}

class MockListLocationRepository extends Mock implements LocationRepository {}

void main() {
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
    when(() => mockLoc.getAllWithPositions()).thenAnswer((_) async => []);
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
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('ricerca placeholder mostra SnackBar', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    await tester.tap(find.byTooltip('Cerca (prossimamente)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('Ricerca'), findsWidgets);
  });

  testWidgets('lista vuota mostra messaggio', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    expect(find.text('Nessun prodotto'), findsOneWidget);
  });

  testWidgets('FAB apre schermata nuovo prodotto', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);

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

  testWidgets('layout wide: tap card mostra riquadro dettaglio', (tester) async {
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

    expect(find.text('Desktop'), findsOneWidget);
    await tester.tap(find.text('Desktop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Seleziona un prodotto dalla lista'), findsNothing);
    expect(find.text('Modifica'), findsOneWidget);
  });
}
