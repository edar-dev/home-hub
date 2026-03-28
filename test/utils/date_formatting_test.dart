import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:housekeep/utils/date_formatting.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it_IT');
  });

  test('formatDate placeholder se null', () {
    expect(formatDate(null), '—');
    expect(formatDate(null, placeholder: 'N/D'), 'N/D');
  });

  test('formatDate formatta data', () {
    final s = formatDate(DateTime(2024, 3, 15));
    expect(s, isNotEmpty);
    expect(s.contains('2024'), isTrue);
  });
}
