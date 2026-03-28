import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/core/theme/app_theme.dart';

void main() {
  test('buildLightTheme e buildDarkTheme usano Material 3', () {
    final light = buildLightTheme();
    final dark = buildDarkTheme();
    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });
}
