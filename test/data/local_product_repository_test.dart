import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/data/local/models/product_hive_model.dart';
import 'package:housekeep/data/local/repositories/local_product_repository.dart';
import 'package:housekeep/domain/entities/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<ProductHiveModel> box;
  late LocalProductRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('housekeep_repo_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
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
    box = await Hive.openBox<ProductHiveModel>(name);
    repository = LocalProductRepository(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(box.name);
  });

  test('getAll returns empty initially', () async {
    expect(await repository.getAll(), isEmpty);
  });

  test('save and getById', () async {
    final p = Product(
      id: 'id-1',
      nome: 'Miele',
      dataAcquisto: DateTime(2025, 3, 1),
      quantitaTotale: 2,
      quantitaRimasta: 2,
    );
    await repository.save(p);
    final all = await repository.getAll();
    expect(all, hasLength(1));
    final got = await repository.getById('id-1');
    expect(got?.nome, 'Miele');
    expect(got?.dataAcquisto?.year, 2025);
  });

  test('update existing id', () async {
    await repository.save(Product(
      id: 'x',
      nome: 'A',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    ));
    await repository.save(Product(
      id: 'x',
      nome: 'B',
      quantitaTotale: 3,
      quantitaRimasta: 1,
    ));
    expect((await repository.getById('x'))?.nome, 'B');
    expect((await repository.getById('x'))?.quantitaTotale, 3);
  });

  test('delete removes product', () async {
    await repository.save(Product(
      id: 'del',
      nome: 'Y',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    ));
    await repository.delete('del');
    expect(await repository.getById('del'), isNull);
    expect(await repository.getAll(), isEmpty);
  });
}
