import '../../../domain/entities/product.dart';
import '../models/product_hive_model.dart';

abstract final class ProductMapper {
  static Product toDomain(ProductHiveModel m) {
    return Product(
      id: m.id,
      nome: m.nome,
      dataAcquisto: m.dataAcquistoMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.dataAcquistoMs!),
      dataScadenza: m.dataScadenzaMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.dataScadenzaMs!),
      dataApertura: m.dataAperturaMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m.dataAperturaMs!),
      quantitaTotale: m.quantitaTotale,
      quantitaRimasta: m.quantitaRimasta,
    );
  }

  static ProductHiveModel toHive(Product p) {
    return ProductHiveModel(
      id: p.id,
      nome: p.nome,
      dataAcquistoMs: p.dataAcquisto?.millisecondsSinceEpoch,
      dataScadenzaMs: p.dataScadenza?.millisecondsSinceEpoch,
      dataAperturaMs: p.dataApertura?.millisecondsSinceEpoch,
      quantitaTotale: p.quantitaTotale,
      quantitaRimasta: p.quantitaRimasta,
    );
  }
}
