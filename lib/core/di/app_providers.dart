import '../../data/local/hive_service.dart';
import '../../data/local/repositories/local_location_repository.dart';
import '../../data/local/repositories/local_product_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';

class AppDependencies {
  AppDependencies({
    required this.hiveService,
    required this.productRepository,
    required this.locationRepository,
  });

  final HiveService hiveService;
  final ProductRepository productRepository;
  final LocationRepository locationRepository;
}

class AppFactory {
  /// [hiveStoragePath] consente test/integration con Hive su path dedicato.
  static Future<AppDependencies> create({String? hiveStoragePath}) async {
    final hiveService = HiveService(storagePath: hiveStoragePath);
    await hiveService.init();
    final box = await hiveService.openProductsBox();
    final productRepository = LocalProductRepository(box);
    final locationsBox = await hiveService.openLocationsBox();
    final positionsBox = await hiveService.openPositionsBox();
    final locationRepository =
        LocalLocationRepository(locationsBox, positionsBox);
    return AppDependencies(
      hiveService: hiveService,
      productRepository: productRepository,
      locationRepository: locationRepository,
    );
  }
}
