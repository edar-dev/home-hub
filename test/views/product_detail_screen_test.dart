import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:housekeep/presentation/views/screens/product_detail_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _MockRepo extends Mock implements ProductRepository {}

void main() {
  late _MockRepo mock;

  setUp(() {
    mock = _MockRepo();
    when(() => mock.getAll()).thenAnswer((_) async => []);
    when(() => mock.save(any())).thenAnswer((_) async {});
    when(() => mock.delete(any())).thenAnswer((_) async {});
    when(() => mock.getById(any())).thenAnswer((_) async => null);
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
  });

  testWidgets('mostra titolo e nome prodotto', (tester) async {
    final p = Product(
      id: 'd1',
      nome: 'Dett',
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    final vm = ProductViewModel(mock);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<ProductRepository>.value(value: mock),
            ChangeNotifierProvider<ProductViewModel>.value(value: vm),
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
