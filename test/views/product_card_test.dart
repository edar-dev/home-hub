import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/presentation/views/widgets/product_card.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    Product product, {
    Size surfaceSize = const Size(800, 220),
  }) async {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it', 'IT')],
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ProductCard(product: product),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('card senza scadenza mostra badge e testi attesi', (tester) async {
    final p = Product(
      id: '1',
      nome: 'Farro',
      quantitaTotale: 3,
      quantitaRimasta: 2,
    );
    await pumpCard(tester, p);
    expect(find.text('Farro'), findsOneWidget);
    expect(find.textContaining('Scadenza:'), findsOneWidget);
    expect(find.text('Nessuna scadenza'), findsWidgets);
    expect(find.text('Senza scadenza'), findsOneWidget);
    expect(find.textContaining('Quantità: 2 / 3'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);
  });

  testWidgets('card scaduta mostra Scaduto e badge', (tester) async {
    final p = Product(
      id: '2',
      nome: 'Latte',
      dataScadenza: DateTime(1999, 1, 1),
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    await pumpCard(tester, p);
    expect(find.text('Latte'), findsOneWidget);
    expect(find.text('Scaduto'), findsWidgets);
  });

  testWidgets('card urgente mostra Urgente', (tester) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final p = Product(
      id: '3',
      nome: 'Yogurt',
      dataScadenza: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    await pumpCard(tester, p);
    expect(find.text('Yogurt'), findsOneWidget);
    expect(find.text('Urgente'), findsOneWidget);
  });

  testWidgets('card OK lontana da scadenza', (tester) async {
    final p = Product(
      id: '4',
      nome: 'Riso',
      dataScadenza: DateTime.now().add(const Duration(days: 90)),
      quantitaTotale: 5,
      quantitaRimasta: 4,
    );
    await pumpCard(tester, p);
    expect(find.text('Riso'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}
