import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/layout/breakpoints.dart';

void main() {
  test('isWideWidth', () {
    expect(isWideWidth(839), isFalse);
    expect(isWideWidth(840), isTrue);
  });

  test('isMediumWidth', () {
    expect(isMediumWidth(599), isFalse);
    expect(isMediumWidth(600), isTrue);
  });
}
