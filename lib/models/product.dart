import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int? dataAcquistoMs;

  @HiveField(3)
  int? dataScadenzaMs;

  @HiveField(4)
  int? dataAperturaMs;

  @HiveField(5)
  int quantitaTotale;

  @HiveField(6)
  int quantitaRimasta;

  Product({
    required this.id,
    required this.nome,
    this.dataAcquistoMs,
    this.dataScadenzaMs,
    this.dataAperturaMs,
    required this.quantitaTotale,
    required this.quantitaRimasta,
  });

  DateTime? get dataAcquisto => dataAcquistoMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(dataAcquistoMs!);

  set dataAcquisto(DateTime? value) =>
      dataAcquistoMs = value?.millisecondsSinceEpoch;

  DateTime? get dataScadenza => dataScadenzaMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(dataScadenzaMs!);

  set dataScadenza(DateTime? value) =>
      dataScadenzaMs = value?.millisecondsSinceEpoch;

  DateTime? get dataApertura => dataAperturaMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(dataAperturaMs!);

  set dataApertura(DateTime? value) =>
      dataAperturaMs = value?.millisecondsSinceEpoch;

  Product copyWith({
    String? id,
    String? nome,
    int? dataAcquistoMs,
    int? dataScadenzaMs,
    int? dataAperturaMs,
    int? quantitaTotale,
    int? quantitaRimasta,
    bool clearDataAcquisto = false,
    bool clearDataScadenza = false,
    bool clearDataApertura = false,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dataAcquistoMs:
          clearDataAcquisto ? null : (dataAcquistoMs ?? this.dataAcquistoMs),
      dataScadenzaMs:
          clearDataScadenza ? null : (dataScadenzaMs ?? this.dataScadenzaMs),
      dataAperturaMs:
          clearDataApertura ? null : (dataAperturaMs ?? this.dataAperturaMs),
      quantitaTotale: quantitaTotale ?? this.quantitaTotale,
      quantitaRimasta: quantitaRimasta ?? this.quantitaRimasta,
    );
  }
}
