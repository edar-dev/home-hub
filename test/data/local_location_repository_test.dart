import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/data/local/models/location_hive_model.dart';
import 'package:housekeep/data/local/models/position_hive_model.dart';
import 'package:housekeep/data/local/models/product_hive_model.dart';
import 'package:housekeep/data/local/repositories/local_location_repository.dart';
import 'package:housekeep/data/local/repositories/local_product_repository.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/exceptions/location_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<LocationHiveModel> locBox;
  late Box<PositionHiveModel> posBox;
  late Box<ProductHiveModel> prodBox;
  late LocalProductRepository productRepo;
  late LocalLocationRepository repository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('housekeep_loc_repo_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocationHiveModelAdapter());
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
    locBox = await Hive.openBox<LocationHiveModel>('loc_$ts');
    posBox = await Hive.openBox<PositionHiveModel>('pos_$ts');
    prodBox = await Hive.openBox<ProductHiveModel>('prod_$ts');
    productRepo = LocalProductRepository(prodBox, posBox);
    repository = LocalLocationRepository(locBox, posBox, productRepo);
  });

  tearDown(() async {
    await locBox.close();
    await posBox.close();
    await prodBox.close();
    await Hive.deleteBoxFromDisk(locBox.name);
    await Hive.deleteBoxFromDisk(posBox.name);
    await Hive.deleteBoxFromDisk(prodBox.name);
  });

  test('getAllWithPositions empty', () async {
    expect(await repository.getAllWithPositions(), isEmpty);
  });

  test('saveLocation and hierarchy', () async {
    await repository.saveLocation(
      const Location(id: 'l1', nome: 'Cucina', descrizione: 'Piano terra'),
    );
    final all = await repository.getAllWithPositions();
    expect(all, hasLength(1));
    expect(all.first.location.nome, 'Cucina');
    expect(all.first.positions, isEmpty);
  });

  test('savePosition requires existing location', () async {
    await expectLater(
      repository.savePosition(
        const StoragePosition(
          id: 'p1',
          nome: 'Frigo',
          locationId: 'missing',
        ),
      ),
      throwsA(isA<LocationException>()),
    );
  });

  test('savePosition and grouping', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'A'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'Zona A', locationId: 'l1'),
    );
    await repository.savePosition(
      const StoragePosition(id: 'p2', nome: 'Zona B', locationId: 'l1'),
    );
    final all = await repository.getAllWithPositions();
    expect(all.first.positions, hasLength(2));
    expect(all.first.positions.first.nome, 'Zona A');
    expect(all.first.positions.last.nome, 'Zona B');
  });

  test('deleteLocation cascades positions', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'X'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'P', locationId: 'l1'),
    );
    await repository.deleteLocation('l1');
    expect(await repository.getAllWithPositions(), isEmpty);
    expect(posBox.isEmpty, isTrue);
  });

  test('deletePosition clears product positionId', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'X'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'P', locationId: 'l1'),
    );
    await productRepo.save(Product(
      id: 'pr1',
      nome: 'Miele',
      quantitaTotale: 1,
      quantitaRimasta: 1,
      positionId: 'p1',
    ));
    await repository.deletePosition('p1');
    expect((await productRepo.getById('pr1'))?.positionId, isNull);
  });

  test('deleteLocation clears products linked to child positions', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'X'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'P', locationId: 'l1'),
    );
    await productRepo.save(Product(
      id: 'pr1',
      nome: 'Miele',
      quantitaTotale: 1,
      quantitaRimasta: 1,
      positionId: 'p1',
    ));
    await repository.deleteLocation('l1');
    expect((await productRepo.getById('pr1'))?.positionId, isNull);
  });

  test('deletePosition', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'X'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'P', locationId: 'l1'),
    );
    await repository.deletePosition('p1');
    final all = await repository.getAllWithPositions();
    expect(all.first.positions, isEmpty);
  });

  test('getLocationWithPositions', () async {
    await repository.saveLocation(const Location(id: 'l1', nome: 'Y'));
    await repository.savePosition(
      const StoragePosition(id: 'p1', nome: 'Q', locationId: 'l1'),
    );
    final one = await repository.getLocationWithPositions('l1');
    expect(one?.positions, hasLength(1));
    expect(await repository.getLocationWithPositions('none'), isNull);
  });
}
