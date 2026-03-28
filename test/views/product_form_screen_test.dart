import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/models/product.dart';
import 'package:housekeep/services/product_storage_service.dart';
import 'package:housekeep/viewmodels/product_view_model.dart';
import 'package:housekeep/views/screens/product_form_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockProductStorageService extends Mock implements ProductStorageService {}

void main() {
  late MockProductStorageService mock;

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

  setUp(() {
    mock = MockProductStorageService();
    when(() => mock.getAll()).thenReturn([]);
    when(() => mock.upsert(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenReturn(null);
  });

  testWidgets('form nuovo prodotto mostra campi', (tester) async {
    final viewModel = ProductViewModel(mock);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductStorageService>.value(value: mock),
            ChangeNotifierProvider<ProductViewModel>.value(value: viewModel),
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
}
