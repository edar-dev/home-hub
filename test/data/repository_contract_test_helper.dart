import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';

/// Contratto CRUD condiviso tra [FakeProductRepository] e Hive.
Future<void> runProductRepositoryCrudContract(ProductRepository repo) async {
  expect(await repo.getAll(), isEmpty);

  final p = Product(
    id: 'id-1',
    nome: 'Miele',
    dataAcquisto: DateTime(2025, 3, 1),
    quantitaTotale: 2,
    quantitaRimasta: 2,
  );
  await repo.save(p);
  var all = await repo.getAll();
  expect(all, hasLength(1));
  final got = await repo.getById('id-1');
  expect(got?.nome, 'Miele');
  expect(got?.dataAcquisto?.year, 2025);

  await repo.save(
    Product(
      id: 'id-1',
      nome: 'B',
      quantitaTotale: 3,
      quantitaRimasta: 1,
    ),
  );
  expect((await repo.getById('id-1'))?.nome, 'B');
  expect((await repo.getById('id-1'))?.quantitaTotale, 3);

  await repo.delete('id-1');
  expect(await repo.getById('id-1'), isNull);
  expect(await repo.getAll(), isEmpty);
}
