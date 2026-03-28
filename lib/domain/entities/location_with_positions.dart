import 'location.dart';
import 'storage_position.dart';

/// Aggregate in memoria: una location con le sue posizioni ordinate dal repository.
class LocationWithPositions {
  const LocationWithPositions({
    required this.location,
    required this.positions,
  });

  final Location location;
  final List<StoragePosition> positions;
}
