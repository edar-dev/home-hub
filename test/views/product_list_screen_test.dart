import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/data/local/hive_service.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockListRepository extends Mock implements ProductRepository {}

class MockListHiveService extends Mock implements HiveService {}

void main() {
  late MockListRepository mockRepo;
  late MockListHiveService mockHive;

  setUp(() {
    mockRepo = MockListRepository();
    mockHive = MockListHiveService();
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    when(() => mockRepo.save(any())).thenAnswer((_) async {});
    when(() => mockRepo.delete(any())).thenAnswer((_) async {});
    when(() => mockRepo.getById(any())).thenAnswer((_) async => null);
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

  Future<void> pumpListLoaded(WidgetTester tester) async {
    await tester.pumpWidget(
      HousekeepApp(
        dependencies: AppDependencies(
          hiveService: mockHive,
          productRepository: mockRepo,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lista vuota mostra messaggio', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);
    expect(find.text('Nessun prodotto'), findsOneWidget);
  });

  testWidgets('FAB apre schermata nuovo prodotto', (tester) async {
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await pumpListLoaded(tester);

    await tester.tap(find.byType(FloatingActionButton));
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
    expect(find.text('1 / 2'), findsOneWidget);
  });
}
