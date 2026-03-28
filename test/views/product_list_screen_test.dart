import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/models/product.dart';
import 'package:housekeep/services/product_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockListStorage extends Mock implements ProductStorageService {}

void main() {
  late MockListStorage mock;

  setUp(() {
    mock = MockListStorage();
    when(() => mock.getAll()).thenReturn([]);
    when(() => mock.upsert(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenReturn(null);
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

  /// Evita [pumpAndSettle]: il [CircularProgressIndicator] durante il load ha animazione infinita.
  Future<void> pumpListLoaded(WidgetTester tester) async {
    await tester.pumpWidget(HousekeepApp(storage: mock));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('lista vuota mostra messaggio', (tester) async {
    when(() => mock.getAll()).thenReturn([]);
    await pumpListLoaded(tester);
    expect(find.text('Nessun prodotto'), findsOneWidget);
  });

  testWidgets('FAB apre schermata nuovo prodotto', (tester) async {
    when(() => mock.getAll()).thenReturn([]);
    await pumpListLoaded(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Nuovo prodotto'), findsOneWidget);
  });

  testWidgets('mostra prodotto in lista', (tester) async {
    when(() => mock.getAll()).thenReturn([
      Product(
        id: 'p1',
        nome: 'Farina',
        quantitaTotale: 2,
        quantitaRimasta: 1,
      ),
    ]);
    await pumpListLoaded(tester);

    expect(find.text('Farina'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
  });
}
