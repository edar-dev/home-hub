import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/presentation/views/widgets/product_card.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('ProductCard — scenario OK', (tester) async {
    await tester.pumpWidgetBuilder(
      const Center(
        child: SizedBox(
          width: 420,
          child: ProductCard(
            product: Product(
              id: 'g',
              nome: 'Pane integrale',
              dataScadenza: null,
              quantitaTotale: 4,
              quantitaRimasta: 2,
            ),
          ),
        ),
      ),
      wrapper: materialAppWrapper(
        theme: ThemeData(useMaterial3: true),
      ),
      surfaceSize: const Size(800, 600),
    );
    await screenMatchesGolden(tester, 'product_card_ok');
  });
}
