import 'app_exception.dart';

/// Errori di persistenza locale (Hive, IO, box non disponibile).
class ProductException extends AppException {
  ProductException(super.message, [super.cause]);
}
