/// Luogo fisico (es. Cucina, Bagno) — dominio puro.
class Location {
  const Location({
    required this.id,
    required this.nome,
    this.descrizione,
    this.updatedAt,
    this.syncVersion = 0,
  });

  final String id;
  final String nome;
  final String? descrizione;
  final DateTime? updatedAt;
  final int syncVersion;

  Location copyWith({
    String? id,
    String? nome,
    String? descrizione,
    DateTime? updatedAt,
    int? syncVersion,
    bool clearDescrizione = false,
    bool clearUpdatedAt = false,
  }) {
    return Location(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: clearDescrizione ? null : (descrizione ?? this.descrizione),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }
}
