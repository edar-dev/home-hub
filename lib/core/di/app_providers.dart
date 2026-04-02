import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/services/photo_storage_service.dart';
import '../../data/local/hive_service.dart';
import '../../data/local/repositories/local_analytics_repository.dart';
import '../../data/local/repositories/local_barcode_repository.dart';
import '../../data/local/repositories/local_category_repository.dart';
import '../../data/local/repositories/local_consumption_repository.dart';
import '../../data/local/repositories/local_location_repository.dart';
import '../../data/local/repositories/local_notification_repository.dart';
import '../../data/local/repositories/local_product_repository.dart';
import '../../data/local/repositories/local_onboarding_repository.dart';
import '../../data/local/repositories/local_shopping_list_repository.dart';
import '../../data/local/repositories/no_op_notification_repository.dart';
import '../../data/local/models/notification_settings_hive_model.dart';
import '../../data/local/models/product_category_hive_model.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/consumption_entry.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/consumption_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/repositories/shopping_list_repository.dart';

/// Dipendenze condivise dall’app dopo bootstrap (Hive + repository locali).
///
/// Costruita da [AppFactory.create]; la UI riceve solo i repository tramite Provider.
class AppDependencies {
  AppDependencies({
    required this.hiveService,
    required this.productRepository,
    required this.locationRepository,
    required this.analyticsRepository,
    required this.barcodeRepository,
    required this.photoStorage,
    required this.notificationRepository,
    required this.categoryRepository,
    ConsumptionRepository? consumptionRepository,
    required this.shoppingListRepository,
    required this.onboardingRepository,
  }) : consumptionRepository =
            consumptionRepository ?? _NoOpConsumptionRepository();

  /// Servizio Hive (init, box); utile per test o shutdown.
  final HiveService hiveService;

  /// CRUD prodotti e query per posizione/luogo.
  final ProductRepository productRepository;

  /// Gerarchia luoghi/posizioni e cancellazioni con integrità sui prodotti.
  final LocationRepository locationRepository;

  /// Statistiche aggregate inventario (read-only).
  final AnalyticsRepository analyticsRepository;

  /// Cache codici a barre.
  final BarcodeRepository barcodeRepository;

  /// Directory radice foto prodotto.
  final PhotoStorageService photoStorage;

  /// Notifiche locali e preferenze.
  final NotificationRepository notificationRepository;

  /// Categorie prodotto.
  final CategoryRepository categoryRepository;

  /// Eventi storici di consumo.
  final ConsumptionRepository consumptionRepository;

  /// Lista spesa e storico.
  final ShoppingListRepository shoppingListRepository;

  /// Onboarding e tour (FASE 5).
  final OnboardingRepository onboardingRepository;
}

class _NoOpConsumptionRepository implements ConsumptionRepository {
  @override
  Future<void> deleteByProductId(String productId) async {}

  @override
  Future<List<ConsumptionEntry>> getByDateRange(
      DateTime start, DateTime end) async {
    return const [];
  }

  @override
  Future<List<ConsumptionEntry>> getByProductId(String productId) async {
    return const [];
  }

  @override
  Future<Map<String, List<ConsumptionEntry>>> getAllGroupedByProductId() async {
    return const {};
  }

  @override
  Future<void> saveEntry(ConsumptionEntry entry) async {}
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

    final fProducts = hiveService.openProductsBox();
    final fLocations = hiveService.openLocationsBox();
    final fPositions = hiveService.openPositionsBox();
    final fConsumption = hiveService.openConsumptionEntriesBox();
    final fBarcodes = hiveService.openBarcodesBox();
    final Future<Box<NotificationSettingsHiveModel>>? fNotif =
        kIsWeb ? null : hiveService.openNotificationSettingsBox();
    final fCategories = hiveService.openCategoriesBox();
    final fShopActive = hiveService.openShoppingActiveBox();
    final fShopHistory = hiveService.openShoppingHistoryBox();
    final fOnbState = hiveService.openOnboardingStateBox();
    final fOnbSettings = hiveService.openOnboardingSettingsBox();

    final box = await fProducts;
    final locationsBox = await fLocations;
    final positionsBox = await fPositions;
    final consumptionBox = await fConsumption;
    final barcodesBox = await fBarcodes;
    final notifBox = fNotif != null ? await fNotif : null;
    final categoriesBox = await fCategories;
    final shoppingActiveBox = await fShopActive;
    final shoppingHistoryBox = await fShopHistory;
    final onboardingStateBox = await fOnbState;
    final onboardingSettingsBox = await fOnbSettings;

    final productRepository = LocalProductRepository(box, positionsBox);
    final consumptionRepository = LocalConsumptionRepository(consumptionBox);
    final locationRepository = LocalLocationRepository(
      locationsBox,
      positionsBox,
      productRepository,
    );
    final analyticsRepository = LocalAnalyticsRepository(
      productRepository,
      locationRepository,
      consumptionRepository,
    );
    final barcodeRepository = LocalBarcodeRepository(barcodesBox);

    final Directory photoRoot;
    if (hiveStoragePath != null) {
      photoRoot = Directory(p.join(hiveStoragePath, 'housekeep_photos'));
    } else {
      final doc = await getApplicationDocumentsDirectory();
      photoRoot = Directory(p.join(doc.path, 'housekeep_photos'));
    }
    await photoRoot.create(recursive: true);
    final photoStorage = PhotoStorageService(photoRoot);

    final NotificationRepository notificationRepository;
    if (kIsWeb) {
      notificationRepository = NoOpNotificationRepository();
    } else {
      notificationRepository = LocalNotificationRepository(
        notifBox!,
        consumptionRepository: consumptionRepository,
      );
    }

    await _seedCategoriesIfEmpty(categoriesBox);
    final categoryRepository = LocalCategoryRepository(
      categoriesBox,
      productRepository,
    );

    final shoppingListRepository = LocalShoppingListRepository(
      shoppingActiveBox,
      shoppingHistoryBox,
      productRepository,
    );

    final onboardingRepository = LocalOnboardingRepository(
      stateBox: onboardingStateBox,
      settingsBox: onboardingSettingsBox,
    );

    return AppDependencies(
      hiveService: hiveService,
      productRepository: productRepository,
      locationRepository: locationRepository,
      analyticsRepository: analyticsRepository,
      barcodeRepository: barcodeRepository,
      photoStorage: photoStorage,
      notificationRepository: notificationRepository,
      categoryRepository: categoryRepository,
      consumptionRepository: consumptionRepository,
      shoppingListRepository: shoppingListRepository,
      onboardingRepository: onboardingRepository,
    );
  }

  static Future<void> _seedCategoriesIfEmpty(
    Box<ProductCategoryHiveModel> box,
  ) async {
    if (box.isNotEmpty) return;
    const rows = <(String, String, int)>[
      ('cat_fruit', 'Frutta e verdura', 0),
      ('cat_dairy', 'Latticini', 1),
      ('cat_pantry', 'Dispensa', 2),
      ('cat_frozen', 'Surgelati', 3),
      ('cat_drinks', 'Bevande', 4),
      ('cat_other', 'Altro', 5),
    ];
    for (final r in rows) {
      await box.put(
        r.$1,
        ProductCategoryHiveModel(
          id: r.$1,
          nome: r.$2,
          sortOrder: r.$3,
        ),
      );
    }
  }
}
