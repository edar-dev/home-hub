import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/config/onboarding_config.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/location_with_positions.dart';
import 'package:housekeep/domain/entities/onboarding_state.dart';
import 'package:housekeep/domain/entities/product.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/services/onboarding_service.dart';

import '../data/fake_product_repository.dart';
import '../support/stub_onboarding_repository.dart';

void main() {
  group('OnboardingService.shouldShowOnboarding', () {
    late StubOnboardingRepository onboarding;
    late FakeProductRepository products;
    late _FakeLocationRepo locations;

    setUp(() {
      onboarding = StubOnboardingRepository();
      products = FakeProductRepository();
      locations = _FakeLocationRepo([]);
    });

    test('epoch + inventario completo → non mostra', () async {
      onboarding.seedState(
        const OnboardingState(
          isCompleted: true,
          lastPromptedFeatureEpoch: 0,
        ),
      );
      const loc = Location(id: 'l1', nome: 'Cucina');
      const pos = StoragePosition(id: 'p1', nome: 'Frigo', locationId: 'l1');
      locations.rows = [
        const LocationWithPositions(location: loc, positions: [pos]),
      ];
      await products.save(
        const Product(
          id: 'a',
          nome: 'A',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      );
      await products.save(
        const Product(
          id: 'b',
          nome: 'B',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      );

      final svc = OnboardingService(
        repository: onboarding,
        productRepository: products,
        locationRepository: locations,
      );
      expect(await svc.shouldShowOnboarding(), false);
    });

    test('epoch + nessun luogo → mostra', () async {
      onboarding.seedState(
        const OnboardingState(
          isCompleted: true,
          lastPromptedFeatureEpoch: 0,
        ),
      );
      final svc = OnboardingService(
        repository: onboarding,
        productRepository: products,
        locationRepository: locations,
      );
      expect(await svc.shouldShowOnboarding(), true);
    });

    test('epoch + luogo ma un solo prodotto → mostra', () async {
      onboarding.seedState(
        const OnboardingState(
          isCompleted: true,
          lastPromptedFeatureEpoch: 0,
        ),
      );
      const loc = Location(id: 'l1', nome: 'Cucina');
      locations.rows = [
        const LocationWithPositions(location: loc, positions: []),
      ];
      await products.save(
        const Product(
          id: 'a',
          nome: 'A',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      );
      final svc = OnboardingService(
        repository: onboarding,
        productRepository: products,
        locationRepository: locations,
      );
      expect(await svc.shouldShowOnboarding(), true);
    });

    test('senza probe inventario: epoch → mostra (compat test)', () async {
      onboarding.seedState(
        const OnboardingState(
          isCompleted: true,
          lastPromptedFeatureEpoch: 0,
        ),
      );
      final svc = OnboardingService(repository: onboarding);
      expect(await svc.shouldShowOnboarding(), true);
    });

    test('inattività: mostra anche con inventario completo', () async {
      onboarding.seedState(
        OnboardingState(
          isCompleted: true,
          lastPromptedFeatureEpoch: OnboardingConfig.featureEpoch,
          lastAppOpenDate: DateTime.now().subtract(const Duration(days: 40)),
        ),
      );
      const loc = Location(id: 'l1', nome: 'Cucina');
      const pos = StoragePosition(id: 'p1', nome: 'Frigo', locationId: 'l1');
      locations.rows = [
        const LocationWithPositions(location: loc, positions: [pos]),
      ];
      await products.save(
        const Product(
          id: 'a',
          nome: 'A',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      );
      await products.save(
        const Product(
          id: 'b',
          nome: 'B',
          quantitaTotale: 1,
          quantitaRimasta: 1,
        ),
      );
      final svc = OnboardingService(
        repository: onboarding,
        productRepository: products,
        locationRepository: locations,
      );
      expect(await svc.shouldShowOnboarding(), true);
    });
  });
}

class _FakeLocationRepo implements LocationRepository {
  _FakeLocationRepo(this.rows);

  List<LocationWithPositions> rows;

  @override
  Future<List<LocationWithPositions>> getAllWithPositions() async => rows;

  @override
  Future<Location?> getLocationById(String id) async =>
      throw UnimplementedError();

  @override
  Future<LocationWithPositions?> getLocationWithPositions(
          String locationId) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteLocation(String id) async => throw UnimplementedError();

  @override
  Future<void> deletePosition(String id) async => throw UnimplementedError();

  @override
  Future<void> saveLocation(Location location) async =>
      throw UnimplementedError();

  @override
  Future<void> savePosition(StoragePosition position) async =>
      throw UnimplementedError();
}
