import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';

void main() {
  group('Product', () {
    test('copyWith preserves or overrides fields', () {
      final p = Product(
        id: 'a',
        nome: 'Latte',
        dataAcquisto: DateTime.fromMillisecondsSinceEpoch(100),
        quantitaTotale: 5,
        quantitaRimasta: 3,
      );
      final q = p.copyWith(nome: 'Yogurt', quantitaRimasta: 2);
      expect(q.id, 'a');
      expect(q.nome, 'Yogurt');
      expect(q.dataAcquisto, p.dataAcquisto);
      expect(q.quantitaTotale, 5);
      expect(q.quantitaRimasta, 2);
    });

    test('copyWith clear flags clear optional dates', () {
      final p = Product(
        id: '1',
        nome: 'X',
        dataAcquisto: DateTime(2020),
        dataScadenza: DateTime(2021),
        dataApertura: DateTime(2022),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      final q = p.copyWith(
        clearDataAcquisto: true,
        clearDataScadenza: true,
        clearDataApertura: true,
      );
      expect(q.dataAcquisto, isNull);
      expect(q.dataScadenza, isNull);
      expect(q.dataApertura, isNull);
    });

    test('isExpired and daysUntilExpiry use date only', () {
      final expired = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(2000, 1, 1),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expired.isExpired, isTrue);
      expect(expired.daysUntilExpiry, lessThan(0));

      final noExpiry = Product(
        id: '2',
        nome: 'B',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(noExpiry.isExpired, isFalse);
      expect(noExpiry.daysUntilExpiry, isNull);
    });

    test('isOpened and isLowStock', () {
      final opened = Product(
        id: '1',
        nome: 'A',
        dataApertura: DateTime(2024, 1, 1),
        quantitaTotale: 2,
        quantitaRimasta: 1,
      );
      expect(opened.isOpened, isTrue);
      expect(opened.isLowStock, isTrue);

      final closed = Product(
        id: '2',
        nome: 'B',
        quantitaTotale: 5,
        quantitaRimasta: 3,
      );
      expect(closed.isOpened, isFalse);
      expect(closed.isLowStock, isFalse);
    });
  });
}
