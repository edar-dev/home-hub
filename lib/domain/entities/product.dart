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
    this.positionId,
    this.updatedAt,
    this.syncVersion = 0,
    this.barcode,
    this.imageRelativePath,
    this.categoryId,
    this.unit = 'unita',
    this.typicalPortion,
    this.price,
  });

  final String id;
  final String nome;
  final DateTime? dataAcquisto;
  final DateTime? dataScadenza;
  final DateTime? dataApertura;
  final int quantitaTotale;
  final int quantitaRimasta;

  /// Opzionale: [StoragePosition.id] (FASE 3). La location si deriva dalla posizione.
  final String? positionId;

  /// Ultima modifica locale (UTC); base per sync/export futuri.
  final DateTime? updatedAt;

  /// Versione lato client per conciliazione con backend (incremento remoto).
  final int syncVersion;

  /// Codice a barre / EAN opzionale (FASE 4).
  final String? barcode;

  /// Path relativo alla directory documenti app per immagine prodotto (una sola).
  final String? imageRelativePath;

  /// [ProductCategory.id] opzionale (FASE 4).
  final String? categoryId;

  /// Unità di misura principale (g, kg, ml, lt, unita, porzioni).
  final String unit;

  /// Porzione tipica opzionale (stessa unità di [unit]).
  final double? typicalPortion;

  /// Prezzo acquisto opzionale (EUR).
  final double? price;

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

  double get quantityUsed => (quantitaTotale - quantitaRimasta).toDouble();

  Product copyWith({
    String? id,
    String? nome,
    DateTime? dataAcquisto,
    DateTime? dataScadenza,
    DateTime? dataApertura,
    int? quantitaTotale,
    int? quantitaRimasta,
    String? positionId,
    DateTime? updatedAt,
    int? syncVersion,
    String? barcode,
    String? imageRelativePath,
    String? categoryId,
    String? unit,
    double? typicalPortion,
    double? price,
    bool clearDataAcquisto = false,
    bool clearDataScadenza = false,
    bool clearDataApertura = false,
    bool clearPositionId = false,
    bool clearUpdatedAt = false,
    bool clearBarcode = false,
    bool clearImageRelativePath = false,
    bool clearCategoryId = false,
    bool clearTypicalPortion = false,
    bool clearPrice = false,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataAcquisto:
          clearDataAcquisto ? null : (dataAcquisto ?? this.dataAcquisto),
      dataScadenza:
          clearDataScadenza ? null : (dataScadenza ?? this.dataScadenza),
      dataApertura:
          clearDataApertura ? null : (dataApertura ?? this.dataApertura),
      quantitaTotale: quantitaTotale ?? this.quantitaTotale,
      quantitaRimasta: quantitaRimasta ?? this.quantitaRimasta,
      positionId: clearPositionId ? null : (positionId ?? this.positionId),
      updatedAt: clearUpdatedAt ? null : (updatedAt ?? this.updatedAt),
      syncVersion: syncVersion ?? this.syncVersion,
      barcode: clearBarcode ? null : (barcode ?? this.barcode),
      imageRelativePath: clearImageRelativePath
          ? null
          : (imageRelativePath ?? this.imageRelativePath),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      unit: unit ?? this.unit,
      typicalPortion:
          clearTypicalPortion ? null : (typicalPortion ?? this.typicalPortion),
      price: clearPrice ? null : (price ?? this.price),
    );
  }
}
