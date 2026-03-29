import '../../../domain/entities/storage_position.dart';
import '../models/position_hive_model.dart';

abstract final class PositionMapper {
  static StoragePosition toDomain(PositionHiveModel m) {
    return StoragePosition(
      id: m.id,
      nome: m.nome,
      descrizione: m.descrizione,
      locationId: m.locationId,
      updatedAt: m.updatedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.updatedAtMs!, isUtc: true),
      syncVersion: m.syncVersion,
    );
  }

  static PositionHiveModel toHive(StoragePosition p) {
    return PositionHiveModel(
      id: p.id,
      nome: p.nome,
      descrizione: p.descrizione,
      locationId: p.locationId,
      updatedAtMs: p.updatedAt?.toUtc().millisecondsSinceEpoch,
      syncVersion: p.syncVersion,
    );
  }
}
