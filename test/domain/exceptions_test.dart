import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/exceptions/app_exception.dart';
import 'package:housekeep/domain/exceptions/product_exception.dart';
import 'package:housekeep/domain/exceptions/validation_exception.dart';

void main() {
  test('AppException toString con e senza cause', () {
    expect(AppException('x').toString(), 'x');
    expect(AppException('x', 'c').toString(), 'x (c)');
  });

  test('ProductException e ValidationException', () {
    expect(ProductException('m').message, 'm');
    expect(ValidationException('v').message, 'v');
  });
}
