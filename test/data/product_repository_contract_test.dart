import 'package:flutter_test/flutter_test.dart';

import 'fake_product_repository.dart';
import 'repository_contract_test_helper.dart';

void main() {
  group('FakeProductRepository', () {
    late FakeProductRepository repo;

    setUp(() {
      repo = FakeProductRepository();
    });

    test('soddisfa contratto CRUD', () async {
      await runProductRepositoryCrudContract(repo);
    });
  });
}
