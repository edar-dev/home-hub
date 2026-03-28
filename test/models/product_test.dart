import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/models/product.dart';

void main() {
  group('Product', () {
    test('dataAcquisto getter/setter roundtrip', () {
      final t = DateTime(2024, 6, 15);
      final p = Product(
        id: '1',
        nome: 'Test',
        quantitaTotale: 2,
        quantitaRimasta: 1,
      );
      p.dataAcquisto = t;
      expect(p.dataAcquistoMs, t.millisecondsSinceEpoch);
      expect(p.dataAcquisto, isNotNull);
      expect(p.dataAcquisto!.year, 2024);
      p.dataAcquisto = null;
      expect(p.dataAcquistoMs, isNull);
    });

    test('copyWith preserves or overrides fields', () {
      final p = Product(
        id: 'a',
        nome: 'Latte',
        dataAcquistoMs: 100,
        quantitaTotale: 5,
        quantitaRimasta: 3,
      );
      final q = p.copyWith(nome: 'Yogurt', quantitaRimasta: 2);
      expect(q.id, 'a');
      expect(q.nome, 'Yogurt');
      expect(q.dataAcquistoMs, 100);
      expect(q.quantitaTotale, 5);
      expect(q.quantitaRimasta, 2);
    });

    test('copyWith clear flags clear optional dates', () {
      final p = Product(
        id: '1',
        nome: 'X',
        dataAcquistoMs: 1,
        dataScadenzaMs: 2,
        dataAperturaMs: 3,
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      final q = p.copyWith(
        clearDataAcquisto: true,
        clearDataScadenza: true,
        clearDataApertura: true,
      );
      expect(q.dataAcquistoMs, isNull);
      expect(q.dataScadenzaMs, isNull);
      expect(q.dataAperturaMs, isNull);
    });
  });
}
