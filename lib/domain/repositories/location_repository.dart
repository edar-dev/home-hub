import '../entities/location.dart';
import '../entities/location_with_positions.dart';
import '../entities/storage_position.dart';

/// Persistenza gerarchia [Location] → [StoragePosition].
///
/// I [Product] si collegano solo tramite `positionId` → [StoragePosition.id]
/// (vedi ADR `docs/adr/0004-product-position-fk.md`).
abstract class LocationRepository {
  /// Tutti i luoghi con le rispettive posizioni caricate.
  Future<List<LocationWithPositions>> getAllWithPositions();

  Future<Location?> getLocationById(String id);

  Future<LocationWithPositions?> getLocationWithPositions(String locationId);

  Future<void> saveLocation(Location location);

  /// Elimina il luogo e le sue posizioni; i prodotti restano ma perdono il link.
  Future<void> deleteLocation(String id);

  Future<void> savePosition(StoragePosition position);

  /// Rimuove la posizione e azzera `positionId` sui prodotti che la usavano.
  Future<void> deletePosition(String id);
}
