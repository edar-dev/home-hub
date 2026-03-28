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

    test('daysUntilExpiry e isExpired con date relative a oggi', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));

      final expiresToday = Product(
        id: 't',
        nome: 'T',
        dataScadenza: today,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expiresToday.isExpired, isFalse);
      expect(expiresToday.daysUntilExpiry, 0);

      final expiresTomorrow = Product(
        id: 'tm',
        nome: 'TM',
        dataScadenza: tomorrow,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expiresTomorrow.isExpired, isFalse);
      expect(expiresTomorrow.daysUntilExpiry, 1);

      final expiredYesterday = Product(
        id: 'y',
        nome: 'Y',
        dataScadenza: yesterday,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(expiredYesterday.isExpired, isTrue);
      expect(expiredYesterday.daysUntilExpiry, lessThan(0));
    });

    test('stesso giorno calendario mese diverso non confonde urgenza', () {
      final a = Product(
        id: '1',
        nome: 'A',
        dataScadenza: DateTime(2035, 1, 15, 8, 0),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      final b = Product(
        id: '2',
        nome: 'B',
        dataScadenza: DateTime(2035, 2, 15, 22, 0),
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(a.daysUntilExpiry, isNot(equals(b.daysUntilExpiry)));
    });

    test('copyWith mantiene stesso comportamento scadenza con ore diverse', () {
      final morning = DateTime(2040, 5, 10, 6, 0);
      final night = DateTime(2040, 5, 10, 23, 59);
      final pAm = Product(
        id: 'x',
        nome: 'X',
        dataScadenza: morning,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      final pPm = pAm.copyWith(dataScadenza: night);
      expect(pAm.daysUntilExpiry, pPm.daysUntilExpiry);
      expect(pAm.isExpired, pPm.isExpired);
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
