import '../../../domain/entities/location.dart';
import '../models/location_hive_model.dart';

abstract final class LocationMapper {
  static Location toDomain(LocationHiveModel m) {
    return Location(
      id: m.id,
      nome: m.nome,
      descrizione: m.descrizione,
      updatedAt: m.updatedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.updatedAtMs!, isUtc: true),
      syncVersion: m.syncVersion,
    );
  }

  static LocationHiveModel toHive(Location l) {
    return LocationHiveModel(
      id: l.id,
      nome: l.nome,
      descrizione: l.descrizione,
      updatedAtMs: l.updatedAt?.toUtc().millisecondsSinceEpoch,
      syncVersion: l.syncVersion,
    );
  }
}
