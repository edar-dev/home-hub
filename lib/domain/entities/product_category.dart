/// Categoria merceologica prodotto (FASE 4).
class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.nome,
    this.sortOrder = 0,
  });

  final String id;
  final String nome;
  final int sortOrder;
}
