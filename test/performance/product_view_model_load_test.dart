import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/presentation/viewmodels/product_view_model.dart';
import 'package:uuid/uuid.dart';

/// Verifica che [ProductViewModel.loadProducts] gestisca un inventario grande senza errori.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const targetCount = 400;

  Directory? hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('housekeep_perf_');
  });

  tearDown(() async {
    await Hive.close();
    final d = hiveDir;
    if (d != null && await d.exists()) {
      await d.delete(recursive: true);
    }
    hiveDir = null;
  });

  test('loadProducts con $targetCount prodotti', () async {
    final deps = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    const uuid = Uuid();
    final now = DateTime.now();
    for (var i = 0; i < targetCount; i++) {
      await deps.productRepository.save(
        Product(
          id: uuid.v4(),
          nome: 'Perf_${i.toString().padLeft(5, '0')}',
          dataAcquisto: now,
          quantitaTotale: 2,
          quantitaRimasta: 2,
          updatedAt: now.toUtc(),
        ),
      );
    }

    final vm = ProductViewModel(
      deps.productRepository,
      deps.locationRepository,
    );
    await vm.loadProducts();

    expect(vm.errorMessage, isNull);
    expect(vm.products.length, targetCount);
    expect(vm.displayedProducts.length, targetCount);

    await deps.hiveService.dispose();
  });
}
