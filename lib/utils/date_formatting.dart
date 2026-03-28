import 'package:intl/intl.dart';

final DateFormat _itDate = DateFormat.yMMMd('it_IT');

/// Formatta una data per l'UI; [placeholder] se null.
String formatDate(DateTime? d, {String placeholder = '—'}) {
  if (d == null) return placeholder;
  return _itDate.format(d);
}
