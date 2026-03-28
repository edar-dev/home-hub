import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/presentation/views/widgets/product_expiry_labels.dart';

void main() {
  group('expiryLineForList', () {
    test('senza scadenza', () {
      final p = Product(
        id: '1',
        nome: 'A',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expiryLineForList(p), 'Nessuna scadenza');
    });

    test('scaduto', () {
      final p = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(1990, 1, 1),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expiryLineForList(p), 'Scaduto');
    });
  });

  group('recommendedUseHint', () {
    test('scaduto', () {
      final p = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(1990, 1, 1),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('scaduto'));
    });

    test('urgente entro settimana', () {
      final d = DateTime.now().add(const Duration(days: 3));
      final p = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(d.year, d.month, d.day),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('settimana'));
    });

    test('aperto da più di una settimana', () {
      final opened = DateTime.now().subtract(const Duration(days: 10));
      final p = Product(
        id: '1',
        nome: 'A',
        dataApertura: opened,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('settimana'));
    });

    test('aperto di recente', () {
      final opened = DateTime.now().subtract(const Duration(days: 2));
      final p = Product(
        id: '1',
        nome: 'A',
        dataApertura: opened,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('aperto'));
    });

    test('senza scadenza', () {
      final p = Product(
        id: '1',
        nome: 'A',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('scadenza'));
    });

    test('default conservazione', () {
      final future = DateTime.now().add(const Duration(days: 30));
      final p = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(future.year, future.month, future.day),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(recommendedUseHint(p), contains('confezione'));
    });
  });
}
