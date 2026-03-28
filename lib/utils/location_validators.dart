import '../domain/entities/location.dart';
import '../domain/entities/storage_position.dart';
import '../domain/exceptions/validation_exception.dart';

/// Validazione pura per [Location], [StoragePosition] e form.
abstract final class LocationValidators {
  static String? validateNome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Il nome è obbligatorio';
    }
    return null;
  }

  static String? validateLocation(Location l) {
    return validateNome(l.nome);
  }

  static String? validatePosition(StoragePosition p) {
    return validateNome(p.nome) ??
        (p.locationId.trim().isEmpty
            ? 'Seleziona un luogo'
            : null);
  }

  static void validateLocationOrThrow(Location l) {
    final msg = validateLocation(l);
    if (msg != null) throw ValidationException(msg);
  }

  static void validatePositionOrThrow(StoragePosition p) {
    final msg = validatePosition(p);
    if (msg != null) throw ValidationException(msg);
  }
}
