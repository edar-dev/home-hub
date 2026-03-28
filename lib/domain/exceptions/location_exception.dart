import 'app_exception.dart';

/// Errori persistenza / IO per locations e positions.
class LocationException extends AppException {
  LocationException(super.message, [super.cause]);
}
