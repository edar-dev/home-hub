import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/presentation/views/widgets/product_detail_body.dart';

void main() {
  Future<void> pumpBody(WidgetTester tester, Product p) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it', 'IT')],
        home: Scaffold(body: ProductDetailBody(product: p)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dettaglio con scadenza futura', (tester) async {
    final d = DateTime.now().add(const Duration(days: 20));
    final p = Product(
      id: '1',
      nome: 'Test',
      dataScadenza: DateTime(d.year, d.month, d.day),
      quantitaTotale: 2,
      quantitaRimasta: 1,
    );
    await pumpBody(tester, p);
    expect(find.text('Test'), findsOneWidget);
    expect(find.textContaining('Giorni alla scadenza'), findsOneWidget);
  });

  testWidgets('dettaglio prodotto scaduto', (tester) async {
    final p = Product(
      id: 'e',
      nome: 'Scaduto',
      dataScadenza: DateTime(1990, 1, 1),
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    await pumpBody(tester, p);
    expect(find.textContaining('scaduto'), findsWidgets);
  });

  testWidgets('dettaglio scade oggi', (tester) async {
    final today = DateTime.now();
    final p = Product(
      id: 't',
      nome: 'Oggi',
      dataScadenza: DateTime(today.year, today.month, today.day),
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
    await pumpBody(tester, p);
    expect(find.textContaining('Scade oggi'), findsOneWidget);
  });

  testWidgets('dettaglio embedded con azioni', (tester) async {
    var editTaps = 0;
    var delTaps = 0;
    final p = Product(
      id: '1',
      nome: 'Emb',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    );
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
          body: ProductDetailBody(
            product: p,
            embedded: true,
            onEdit: () => editTaps++,
            onDelete: () => delTaps++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifica'));
    await tester.tap(find.text('Elimina'));
    expect(editTaps, 1);
    expect(delTaps, 1);
  });
}
