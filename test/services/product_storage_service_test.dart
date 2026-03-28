import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/models/product.dart';
import 'package:housekeep/services/product_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Product> box;
  late ProductStorageService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('housekeep_hive_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    final name = 'box_${DateTime.now().microsecondsSinceEpoch}';
    box = await Hive.openBox<Product>(name);
    service = ProductStorageService(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(box.name);
  });

  test('getAll returns empty initially', () {
    expect(service.getAll(), isEmpty);
  });

  test('upsert and getById', () async {
    final p = Product(
      id: 'id-1',
      nome: 'Miele',
      quantitaTotale: 2,
      quantitaRimasta: 2,
    )..dataAcquisto = DateTime(2025, 3, 1);

    await service.upsert(p);
    expect(service.getAll(), hasLength(1));
    final got = service.getById('id-1');
    expect(got?.nome, 'Miele');
    expect(got?.dataAcquisto?.year, 2025);
  });

  test('update existing id', () async {
    await service.upsert(Product(
      id: 'x',
      nome: 'A',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    ));
    await service.upsert(Product(
      id: 'x',
      nome: 'B',
      quantitaTotale: 3,
      quantitaRimasta: 1,
    ));
    expect(service.getById('x')?.nome, 'B');
    expect(service.getById('x')?.quantitaTotale, 3);
  });

  test('delete removes product', () async {
    await service.upsert(Product(
      id: 'del',
      nome: 'Y',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    ));
    await service.delete('del');
    expect(service.getById('del'), isNull);
    expect(service.getAll(), isEmpty);
  });
}
