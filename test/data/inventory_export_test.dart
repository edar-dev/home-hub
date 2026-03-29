import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/data/export/inventory_export.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockProducts extends Mock implements ProductRepository {}

class _MockLocations extends Mock implements LocationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'x',
        nome: 'x',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
    registerFallbackValue(const Location(id: 'x', nome: 'x'));
    registerFallbackValue(
      const StoragePosition(id: 'x', nome: 'x', locationId: 'x'),
    );
  });

  test('buildDocument schemaVersion 1 e struttura minima', () async {
    final products = _MockProducts();
    final locations = _MockLocations();

    final p = Product(
      id: 'p1',
      nome: 'Miele',
      quantitaTotale: 2,
      quantitaRimasta: 1,
      syncVersion: 2,
      updatedAt: DateTime.utc(2026, 3, 1, 12),
    );
    final loc = const Location(id: 'l1', nome: 'Cucina');
    final pos = const StoragePosition(
      id: 's1',
      nome: 'Dispensa',
      locationId: 'l1',
    );

    when(() => products.getAll()).thenAnswer((_) async => [p]);
    when(() => locations.getAllWithPositions()).thenAnswer(
      (_) async => [
        LocationWithPositions(location: loc, positions: [pos]),
      ],
    );

    final doc = await const InventoryExportService().buildDocument(
      products: products,
      locations: locations,
      exportedAt: DateTime.utc(2026, 3, 28),
    );

    expect(doc['schemaVersion'], InventoryExportSchema.currentVersion);
    expect(doc['exportedAt'], '2026-03-28T00:00:00.000Z');
    expect(doc['products'], isA<List<dynamic>>());
    expect(doc['locations'], isA<List<dynamic>>());
    expect(doc['positions'], isA<List<dynamic>>());

    final pj = (doc['products'] as List<dynamic>).single as Map<String, dynamic>;
    expect(pj['id'], 'p1');
    expect(pj['syncVersion'], 2);
    expect(pj['updatedAt'], '2026-03-01T12:00:00.000Z');

    final lj = (doc['locations'] as List<dynamic>).single as Map<String, dynamic>;
    expect(lj['nome'], 'Cucina');

    final sj = (doc['positions'] as List<dynamic>).single as Map<String, dynamic>;
    expect(sj['locationId'], 'l1');
  });
}
