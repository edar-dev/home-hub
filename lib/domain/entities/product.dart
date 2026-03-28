/// Entità di dominio prodotto (nessuna dipendenza da Flutter/Hive).
class Product {
  const Product({
    required this.id,
    required this.nome,
    this.dataAcquisto,
    this.dataScadenza,
    this.dataApertura,
    required this.quantitaTotale,
    required this.quantitaRimasta,
  });

  final String id;
  final String nome;
  final DateTime? dataAcquisto;
  final DateTime? dataScadenza;
  final DateTime? dataApertura;
  final int quantitaTotale;
  final int quantitaRimasta;

  /// Confronto solo sulla data locale; senza scadenza non è considerato scaduto.
  bool get isExpired {
    final d = dataScadenza;
    if (d == null) return false;
    final today = DateTime.now();
    final end = DateTime(d.year, d.month, d.day);
    final start = DateTime(today.year, today.month, today.day);
    return end.isBefore(start);
  }

  /// Giorni fino alla scadenza (negativi se scaduto); `null` se non c’è scadenza.
  int? get daysUntilExpiry {
    final d = dataScadenza;
    if (d == null) return null;
    final today = DateTime.now();
    final a = DateTime(today.year, today.month, today.day);
    final b = DateTime(d.year, d.month, d.day);
    return b.difference(a).inDays;
  }

  bool get isOpened => dataApertura != null;

  /// Soglia semplice per “poca quantità” in inventario domestico.
  bool get isLowStock => quantitaRimasta <= 1;

  Product copyWith({
    String? id,
    String? nome,
    DateTime? dataAcquisto,
    DateTime? dataScadenza,
    DateTime? dataApertura,
    int? quantitaTotale,
    int? quantitaRimasta,
    bool clearDataAcquisto = false,
    bool clearDataScadenza = false,
    bool clearDataApertura = false,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataAcquisto: clearDataAcquisto ? null : (dataAcquisto ?? this.dataAcquisto),
      dataScadenza: clearDataScadenza ? null : (dataScadenza ?? this.dataScadenza),
      dataApertura: clearDataApertura ? null : (dataApertura ?? this.dataApertura),
      quantitaTotale: quantitaTotale ?? this.quantitaTotale,
      quantitaRimasta: quantitaRimasta ?? this.quantitaRimasta,
    );
  }
}
