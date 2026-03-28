/// Luogo fisico (es. Cucina, Bagno) — dominio puro.
class Location {
  const Location({
    required this.id,
    required this.nome,
    this.descrizione,
  });

  final String id;
  final String nome;
  final String? descrizione;

  Location copyWith({
    String? id,
    String? nome,
    String? descrizione,
    bool clearDescrizione = false,
  }) {
    return Location(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: clearDescrizione ? null : (descrizione ?? this.descrizione),
    );
  }
}
