/// Posizione all'interno di una [Location] (es. Frigo, Dispensa).
/// Nome file/classe evita clash con API di layout Flutter.
class StoragePosition {
  const StoragePosition({
    required this.id,
    required this.nome,
    this.descrizione,
    required this.locationId,
    this.updatedAt,
    this.syncVersion = 0,
  });

  final String id;
  final String nome;
  final String? descrizione;
  final String locationId;
  final DateTime? updatedAt;
  final int syncVersion;

  StoragePosition copyWith({
    String? id,
    String? nome,
    String? descrizione,
    String? locationId,
    DateTime? updatedAt,
    int? syncVersion,
    bool clearDescrizione = false,
    bool clearUpdatedAt = false,
  }) {
    return StoragePosition(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: clearDescrizione ? null : (descrizione ?? this.descrizione),
      locationId: locationId ?? this.locationId,
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }
}
