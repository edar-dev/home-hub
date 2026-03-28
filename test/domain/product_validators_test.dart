import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/exceptions/validation_exception.dart';
import 'package:housekeep/utils/product_validators.dart';

void main() {
  group('ProductValidators', () {
    test('validateNome rejects empty', () {
      expect(ProductValidators.validateNome(null), isNotNull);
      expect(ProductValidators.validateNome(''), isNotNull);
      expect(ProductValidators.validateNome('   '), isNotNull);
      expect(ProductValidators.validateNome('Pane'), isNull);
    });

    test('validateQuantitaTotale', () {
      expect(ProductValidators.validateQuantitaTotale(0), isNotNull);
      expect(ProductValidators.validateQuantitaTotale(1), isNull);
    });

    test('validateQuantitaRimasta', () {
      expect(ProductValidators.validateQuantitaRimasta(-1, 5), isNotNull);
      expect(ProductValidators.validateQuantitaRimasta(6, 5), isNotNull);
      expect(ProductValidators.validateQuantitaRimasta(3, 5), isNull);
      expect(ProductValidators.validateQuantitaRimasta(5, 5), isNull);
    });

    test('validateDateOrder', () {
      final a = DateTime(2025, 1, 10);
      final sOk = DateTime(2025, 12, 1);
      final sBad = DateTime(2025, 1, 1);
      expect(ProductValidators.validateDateOrder(a, sOk), isNull);
      expect(ProductValidators.validateDateOrder(a, sBad), isNotNull);
      expect(ProductValidators.validateDateOrder(null, sOk), isNull);
    });

    test('validateProductOrThrow lancia ValidationException se invalido', () {
      final bad = Product(
        id: '1',
        nome: '',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      );
      expect(
        () => ProductValidators.validateProductOrThrow(bad),
        throwsA(isA<ValidationException>()),
      );
      final good = Product(
        id: '1',
        nome: 'Ok',
        quantitaTotale: 2,
        quantitaRimasta: 2,
      );
      expect(() => ProductValidators.validateProductOrThrow(good), returnsNormally);
    });

    test('validateProduct aggregates rules', () {
      final bad = Product(
        id: '1',
        nome: '',
        quantitaTotale: 0,
        quantitaRimasta: 0,
      );
      expect(ProductValidators.validateProduct(bad), isNotNull);

      final good = Product(
        id: '1',
        nome: 'Olio',
        quantitaTotale: 2,
        quantitaRimasta: 1,
      );
      expect(ProductValidators.validateProduct(good), isNull);
    });
  });
}
