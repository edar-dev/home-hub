/// Posizione all'interno di una [Location] (es. Frigo, Dispensa).
/// Nome file/classe evita clash con API di layout Flutter.
class StoragePosition {
  const StoragePosition({
    required this.id,
    required this.nome,
    this.descrizione,
    required this.locationId,
  });

  final String id;
  final String nome;
  final String? descrizione;
  final String locationId;

  StoragePosition copyWith({
    String? id,
    String? nome,
    String? descrizione,
    String? locationId,
    bool clearDescrizione = false,
  }) {
    return StoragePosition(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: clearDescrizione ? null : (descrizione ?? this.descrizione),
      locationId: locationId ?? this.locationId,
    );
  }
}
