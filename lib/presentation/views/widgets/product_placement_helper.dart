import '../../../domain/entities/location_with_positions.dart';
import '../../../domain/entities/product.dart';

/// Indice [StoragePosition.id] → (nome luogo, nome posizione).
Map<String, (String locationNome, String positionNome)> buildPlacementIndex(
  List<LocationWithPositions> items,
) {
  final m = <String, (String, String)>{};
  for (final row in items) {
    for (final pos in row.positions) {
      m[pos.id] = (row.location.nome, pos.nome);
    }
  }
  return m;
}

/// Riga UI per card/dettaglio; `null` se senza posizione o dati mancanti.
String? placementLineForProduct(
  Product product,
  Map<String, (String, String)> index,
) {
  final pid = product.positionId;
  if (pid == null) return null;
  final entry = index[pid];
  if (entry == null) {
    return 'Posizione non più disponibile';
  }
  return 'Luogo: ${entry.$1} · ${entry.$2}';
}
