import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/data/local/mappers/product_mapper.dart';
import 'package:housekeep/data/local/models/product_hive_model.dart';
import 'package:housekeep/domain/entities/product.dart';

void main() {
  group('ProductMapper', () {
    test('round trip preserves data', () {
      final domain = Product(
        id: 'x',
        nome: 'Sale',
        dataAcquisto: DateTime(2025, 4, 1, 12, 30),
        dataScadenza: DateTime(2026, 1, 1),
        dataApertura: null,
        quantitaTotale: 3,
        quantitaRimasta: 2,
      );
      final hive = ProductMapper.toHive(domain);
      final back = ProductMapper.toDomain(hive);
      expect(back.id, domain.id);
      expect(back.nome, domain.nome);
      expect(back.dataAcquisto, domain.dataAcquisto);
      expect(back.dataScadenza, domain.dataScadenza);
      expect(back.dataApertura, isNull);
      expect(back.quantitaTotale, 3);
      expect(back.quantitaRimasta, 2);
      expect(back.positionId, isNull);
    });

    test('round trip with positionId', () {
      final domain = Product(
        id: 'x',
        nome: 'Y',
        quantitaTotale: 1,
        quantitaRimasta: 1,
        positionId: 'pos-1',
      );
      final back = ProductMapper.toDomain(ProductMapper.toHive(domain));
      expect(back.positionId, 'pos-1');
    });

    test('toDomain from raw hive model', () {
      final m = ProductHiveModel(
        id: '1',
        nome: 'Z',
        dataAcquistoMs: DateTime(2020).millisecondsSinceEpoch,
        quantitaTotale: 1,
        quantitaRimasta: 0,
      );
      final p = ProductMapper.toDomain(m);
      expect(p.dataAcquisto?.year, 2020);
    });
  });
}
