import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';
import 'package:housekeep/data/local/hive_service.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/repositories/product_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHive extends Mock implements HiveService {}

class _MockRepo extends Mock implements ProductRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'fb',
        nome: 'fb',
        quantitaTotale: 1,
        quantitaRimasta: 1,
      ),
    );
  });

  testWidgets('HousekeepApp si costruisce', (tester) async {
    final mockHive = _MockHive();
    final mockRepo = _MockRepo();
    when(() => mockRepo.getAll()).thenAnswer((_) async => []);
    await tester.pumpWidget(
      HousekeepApp(
        dependencies: AppDependencies(
          hiveService: mockHive,
          productRepository: mockRepo,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inventario'), findsOneWidget);
  });
}
