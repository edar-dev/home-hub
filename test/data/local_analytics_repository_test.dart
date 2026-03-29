import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Directory? dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('housekeep_analytics_');
  });

  tearDown(() async {
    await Hive.close();
    final d = dir;
    if (d != null && await d.exists()) {
      await d.delete(recursive: true);
    }
    dir = null;
  });

  test('getMetrics e distribuzione luogo', () async {
    final deps = await AppFactory.create(hiveStoragePath: dir!.path);
    const uuid = Uuid();
    final locId = uuid.v4();
    await deps.locationRepository.saveLocation(
      Location(id: locId, nome: 'Cucina'),
    );
    final posId = uuid.v4();
    await deps.locationRepository.savePosition(
      StoragePosition(id: posId, nome: 'Frigo', locationId: locId),
    );
    await deps.productRepository.save(
      Product(
        id: uuid.v4(),
        nome: 'Latte',
        quantitaTotale: 2,
        quantitaRimasta: 1,
        positionId: posId,
        dataScadenza: DateTime.now().add(const Duration(days: 3)),
      ),
    );

    final analytics = deps.analyticsRepository;
    final now = DateTime.now();
    final m = await analytics.getMetrics(
      startDate: DateTime(now.year, now.month - 1, now.day),
      endDate: DateTime(now.year, now.month, now.day),
    );
    expect(m.totalProducts, 1);

    final pie = await analytics.getProductDistributionByLocation();
    expect(pie.any((e) => e.label == 'Cucina'), isTrue);
  });
}
