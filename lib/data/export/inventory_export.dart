import 'dart:convert';

import '../../domain/entities/location.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/storage_position.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';

/// Versione del documento export (incrementare solo per breaking change formato).
abstract final class InventoryExportSchema {
  static const int currentVersion = 1;
}

/// Costruisce un payload JSON versionato per backup / futuro import / sync.
class InventoryExportService {
  const InventoryExportService();

  Future<Map<String, dynamic>> buildDocument({
    required ProductRepository products,
    required LocationRepository locations,
    DateTime? exportedAt,
  }) async {
    final now = (exportedAt ?? DateTime.now()).toUtc();
    final plist = await products.getAll();
    final hierarchy = await locations.getAllWithPositions();

    return {
      'schemaVersion': InventoryExportSchema.currentVersion,
      'exportedAt': now.toIso8601String(),
      'products': plist.map(_productToJson).toList(),
      'locations': hierarchy.map((e) => _locationToJson(e.location)).toList(),
      'positions': hierarchy
          .expand((e) => e.positions.map(_positionToJson))
          .toList(),
    };
  }

  Future<String> buildJsonString({
    required ProductRepository products,
    required LocationRepository locations,
    DateTime? exportedAt,
  }) async {
    final doc = await buildDocument(
      products: products,
      locations: locations,
      exportedAt: exportedAt,
    );
    return const JsonEncoder.withIndent('  ').convert(doc);
  }
}

Map<String, dynamic> _productToJson(Product p) {
  return {
    'id': p.id,
    'nome': p.nome,
    'dataAcquisto': p.dataAcquisto?.toUtc().toIso8601String(),
    'dataScadenza': p.dataScadenza?.toUtc().toIso8601String(),
    'dataApertura': p.dataApertura?.toUtc().toIso8601String(),
    'quantitaTotale': p.quantitaTotale,
    'quantitaRimasta': p.quantitaRimasta,
    'positionId': p.positionId,
    'updatedAt': p.updatedAt?.toUtc().toIso8601String(),
    'syncVersion': p.syncVersion,
  };
}

Map<String, dynamic> _locationToJson(Location l) {
  return {
    'id': l.id,
    'nome': l.nome,
    'descrizione': l.descrizione,
    'updatedAt': l.updatedAt?.toUtc().toIso8601String(),
    'syncVersion': l.syncVersion,
  };
}

Map<String, dynamic> _positionToJson(StoragePosition p) {
  return {
    'id': p.id,
    'nome': p.nome,
    'descrizione': p.descrizione,
    'locationId': p.locationId,
    'updatedAt': p.updatedAt?.toUtc().toIso8601String(),
    'syncVersion': p.syncVersion,
  };
}
