import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:housekeep/presentation/views/screens/product_form_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFormRepository extends Mock implements ProductRepository {}

void main() {
  late MockFormRepository mock;

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
    mock = MockFormRepository();
    when(() => mock.getAll()).thenAnswer((_) async => []);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenAnswer((_) async => null);
  });

  testWidgets('form nuovo prodotto mostra campi', (tester) async {
    final viewModel = ProductViewModel(mock);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
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
