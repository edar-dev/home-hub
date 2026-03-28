import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/data/local/models/position_hive_model.dart';
import 'package:housekeep/data/local/models/product_hive_model.dart';
import 'package:housekeep/data/local/repositories/local_product_repository.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/exceptions/product_exception.dart';

import 'repository_contract_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<ProductHiveModel> box;
  late Box<PositionHiveModel> posBox;
  late LocalProductRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('housekeep_repo_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PositionHiveModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    final ts = DateTime.now().microsecondsSinceEpoch;
    box = await Hive.openBox<ProductHiveModel>('prod_$ts');
    posBox = await Hive.openBox<PositionHiveModel>('pos_$ts');
    repository = LocalProductRepository(box, posBox);
  });

  tearDown(() async {
    await box.close();
    await posBox.close();
    await Hive.deleteBoxFromDisk(box.name);
    await Hive.deleteBoxFromDisk(posBox.name);
  });

  test('getAll returns empty initially', () async {
    expect(await repository.getAll(), isEmpty);
  });

  test('soddisfa contratto CRUD condiviso', () async {
    await runProductRepositoryCrudContract(repository);
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

  test('save rejects unknown positionId', () async {
    final p = Product(
      id: 'p1',
      nome: 'X',
      quantitaTotale: 1,
      quantitaRimasta: 1,
      positionId: 'missing-pos',
    );
    await expectLater(
      repository.save(p),
      throwsA(isA<ProductException>()),
    );
  });

  test('getByPositionId and getByLocationId', () async {
    await posBox.put(
      'pos1',
      PositionHiveModel(
        id: 'pos1',
        nome: 'Frigo',
        locationId: 'loc1',
      ),
    );
    await repository.save(Product(
      id: 'a',
      nome: 'Latte',
      quantitaTotale: 1,
      quantitaRimasta: 1,
      positionId: 'pos1',
    ));
    await repository.save(Product(
      id: 'b',
      nome: 'Pane',
      quantitaTotale: 1,
      quantitaRimasta: 1,
    ));
    final byPos = await repository.getByPositionId('pos1');
    expect(byPos, hasLength(1));
    expect(byPos.first.nome, 'Latte');
    final byLoc = await repository.getByLocationId('loc1');
    expect(byLoc, hasLength(1));
    expect(byLoc.first.nome, 'Latte');
  });

  test('clearPositionIdsForPositions', () async {
    await posBox.put(
      'pos1',
      PositionHiveModel(
        id: 'pos1',
        nome: 'F',
        locationId: 'l1',
      ),
    );
    await repository.save(Product(
      id: 'a',
      nome: 'X',
      quantitaTotale: 1,
      quantitaRimasta: 1,
      positionId: 'pos1',
    ));
    await repository.clearPositionIdsForPositions(['pos1']);
    final got = await repository.getById('a');
    expect(got?.positionId, isNull);
  });

  test('legacy hive record without field 7 reads positionId null', () async {
    await box.put(
      'legacy',
      ProductHiveModel(
        id: 'legacy',
        nome: 'Old',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
    final got = await repository.getById('legacy');
    expect(got?.positionId, isNull);
  });
}
