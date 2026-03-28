import 'app_exception.dart';

/// Regole di validazione prodotto non soddisfatte.
class ValidationException extends AppException {
  ValidationException(super.message, [super.cause]);
}
