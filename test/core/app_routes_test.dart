import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/core/navigation/app_routes.dart';

void main() {
  test('costanti route', () {
    expect(AppRoutes.list, '/');
    expect(AppRoutes.detail, '/detail');
    expect(AppRoutes.form, '/form');
  });
}
