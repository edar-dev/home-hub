import '../../data/local/hive_service.dart';
import '../../data/local/repositories/local_product_repository.dart';
import '../../domain/repositories/product_repository.dart';

class AppDependencies {
  AppDependencies({
    required this.hiveService,
    required this.productRepository,
  });

  final HiveService hiveService;
  final ProductRepository productRepository;
}

class AppFactory {
  /// [hiveStoragePath] consente test/integration con Hive su path dedicato.
  static Future<AppDependencies> create({String? hiveStoragePath}) async {
    final hiveService = HiveService(storagePath: hiveStoragePath);
    await hiveService.init();
    final box = await hiveService.openProductsBox();
    final productRepository = LocalProductRepository(box);
    return AppDependencies(
      hiveService: hiveService,
      productRepository: productRepository,
    );
  }
}
