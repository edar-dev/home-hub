import '../entities/location.dart';
import '../entities/location_with_positions.dart';
import '../entities/storage_position.dart';

/// Persistenza gerarchia Location → StoragePosition.
///
/// FASE 3: collegamento [Product] ↔ posizione tramite `positionId` verso [StoragePosition.id].
abstract class LocationRepository {
  Future<List<LocationWithPositions>> getAllWithPositions();

  Future<Location?> getLocationById(String id);

  Future<LocationWithPositions?> getLocationWithPositions(String locationId);

  Future<void> saveLocation(Location location);

  Future<void> deleteLocation(String id);

  Future<void> savePosition(StoragePosition position);

  Future<void> deletePosition(String id);
}
