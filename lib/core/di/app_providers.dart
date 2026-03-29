import '../../data/local/hive_service.dart';
import '../../data/local/repositories/local_location_repository.dart';
import '../../data/local/repositories/local_product_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/product_repository.dart';

/// Dipendenze condivise dall’app dopo bootstrap (Hive + repository locali).
///
/// Costruita da [AppFactory.create]; la UI riceve solo i repository tramite Provider.
class AppDependencies {
  AppDependencies({
    required this.hiveService,
    required this.productRepository,
    required this.locationRepository,
  });

  /// Servizio Hive (init, box); utile per test o shutdown.
  final HiveService hiveService;

  /// CRUD prodotti e query per posizione/luogo.
  final ProductRepository productRepository;

  /// Gerarchia luoghi/posizioni e cancellazioni con integrità sui prodotti.
  final LocationRepository locationRepository;
}

/// Fabbrica di [AppDependencies] per `main` e test.
///
/// Apre i box Hive, registra gli adapter e istanzia i repository concreti.
class AppFactory {
  /// Inizializza Hive e restituisce repository pronti all’uso.
  ///
  /// [hiveStoragePath] (directory esistente) usa `Hive.init` al posto di
  /// `Hive.initFlutter` — utile in test/integration senza path_provider.
  static Future<AppDependencies> create({String? hiveStoragePath}) async {
    final hiveService = HiveService(storagePath: hiveStoragePath);
    await hiveService.init();
    final box = await hiveService.openProductsBox();
    final locationsBox = await hiveService.openLocationsBox();
    final positionsBox = await hiveService.openPositionsBox();
    final productRepository = LocalProductRepository(box, positionsBox);
    final locationRepository = LocalLocationRepository(
      locationsBox,
      positionsBox,
      productRepository,
    );
    return AppDependencies(
      hiveService: hiveService,
      productRepository: productRepository,
      locationRepository: locationRepository,
    );
  }
}
