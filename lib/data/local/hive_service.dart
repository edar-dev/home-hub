import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/exceptions/location_exception.dart';
import '../../domain/exceptions/product_exception.dart';
import '../../utils/onboarding_constants.dart';
import 'models/location_hive_model.dart';
import 'models/position_hive_model.dart';
import 'models/barcode_cache_hive_model.dart';
import 'models/notification_settings_hive_model.dart';
import 'models/product_category_hive_model.dart';
import 'models/product_hive_model.dart';
import 'models/shopping_list_hive_model.dart';
import 'models/onboarding_state_hive_model.dart';
import 'models/onboarding_settings_hive_model.dart';
import 'models/shopping_list_item_hive_model.dart';

/// Nome Hive box prodotti ([ProductHiveModel]).
const String kProductsBoxName = 'products';

/// Nome Hive box luoghi ([LocationHiveModel]).
const String kLocationsBoxName = 'locations';

/// Nome Hive box posizioni di stoccaggio ([PositionHiveModel]).
const String kPositionsBoxName = 'positions';

/// Nome Hive box cache codici a barre ([BarcodeCacheHiveModel]).
const String kBarcodesBoxName = 'barcodes';

/// Nome Hive box impostazioni notifiche ([NotificationSettingsHiveModel]).
const String kNotificationSettingsBoxName = 'notification_settings';

/// Box categorie prodotto ([ProductCategoryHiveModel]).
const String kCategoriesBoxName = 'categories';

/// Lista spesa attiva ([ShoppingListHiveModel]).
const String kShoppingActiveBoxName = 'shopping_active';

/// Storico liste completate.
const String kShoppingHistoryBoxName = 'shopping_history';

/// Accesso a Hive: init, registrazione adapter, apertura box, [dispose].
///
/// [storagePath] (es. directory temporanea) usa [Hive.init] invece di
/// [Hive.initFlutter] — utile per test/integration senza path_provider.
class HiveService {
  HiveService({this.storagePath});

  /// Se non null, Hive usa questa directory su disco.
  final String? storagePath;

  Future<void> init() async {
    try {
      if (storagePath != null) {
        Hive.init(storagePath!);
      } else {
        await Hive.initFlutter();
      }
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(LocationHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PositionHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(BarcodeCacheHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(NotificationSettingsHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(ProductCategoryHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(ShoppingListItemHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(ShoppingListHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(OnboardingStateHiveModelAdapter());
      }
      if (!Hive.isAdapterRegistered(9)) {
        Hive.registerAdapter(OnboardingSettingsHiveModelAdapter());
      }
    } catch (e, st) {
      debugPrint('HiveService.init failed: $e\n$st');
      throw ProductException('Impossibile inizializzare il database locale', e);
    }
  }

  Future<Box<ProductHiveModel>> openProductsBox() async {
    try {
      return await Hive.openBox<ProductHiveModel>(kProductsBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openProductsBox failed: $e\n$st');
      throw ProductException('Impossibile aprire il database locale', e);
    }
  }

  Future<Box<LocationHiveModel>> openLocationsBox() async {
    try {
      return await Hive.openBox<LocationHiveModel>(kLocationsBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openLocationsBox failed: $e\n$st');
      throw LocationException('Impossibile aprire il database luoghi', e);
    }
  }

  Future<Box<PositionHiveModel>> openPositionsBox() async {
    try {
      return await Hive.openBox<PositionHiveModel>(kPositionsBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openPositionsBox failed: $e\n$st');
      throw LocationException('Impossibile aprire il database posizioni', e);
    }
  }

  Future<Box<BarcodeCacheHiveModel>> openBarcodesBox() async {
    try {
      return await Hive.openBox<BarcodeCacheHiveModel>(kBarcodesBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openBarcodesBox failed: $e\n$st');
      throw ProductException('Impossibile aprire la cache codici', e);
    }
  }

  Future<Box<NotificationSettingsHiveModel>> openNotificationSettingsBox() async {
    try {
      return await Hive.openBox<NotificationSettingsHiveModel>(
        kNotificationSettingsBoxName,
      );
    } catch (e, st) {
      debugPrint('HiveService.openNotificationSettingsBox failed: $e\n$st');
      throw ProductException('Impossibile aprire le impostazioni notifiche', e);
    }
  }

  Future<Box<ProductCategoryHiveModel>> openCategoriesBox() async {
    try {
      return await Hive.openBox<ProductCategoryHiveModel>(kCategoriesBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openCategoriesBox failed: $e\n$st');
      throw ProductException('Impossibile aprire le categorie', e);
    }
  }

  Future<Box<ShoppingListHiveModel>> openShoppingActiveBox() async {
    try {
      return await Hive.openBox<ShoppingListHiveModel>(kShoppingActiveBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openShoppingActiveBox failed: $e\n$st');
      throw ProductException('Impossibile aprire la lista spesa', e);
    }
  }

  Future<Box<ShoppingListHiveModel>> openShoppingHistoryBox() async {
    try {
      return await Hive.openBox<ShoppingListHiveModel>(kShoppingHistoryBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openShoppingHistoryBox failed: $e\n$st');
      throw ProductException('Impossibile aprire lo storico liste', e);
    }
  }

  Future<Box<OnboardingStateHiveModel>> openOnboardingStateBox() async {
    try {
      return await Hive.openBox<OnboardingStateHiveModel>(kOnboardingStateBoxName);
    } catch (e, st) {
      debugPrint('HiveService.openOnboardingStateBox failed: $e\n$st');
      throw ProductException('Impossibile aprire lo stato onboarding', e);
    }
  }

  Future<Box<OnboardingSettingsHiveModel>> openOnboardingSettingsBox() async {
    try {
      return await Hive.openBox<OnboardingSettingsHiveModel>(
        kOnboardingSettingsBoxName,
      );
    } catch (e, st) {
      debugPrint('HiveService.openOnboardingSettingsBox failed: $e\n$st');
      throw ProductException('Impossibile aprire le impostazioni onboarding', e);
    }
  }

  /// Chiude tutti i box Hive. Dopo la chiamata i repository che tengono
  /// riferimenti ai box non sono più validi — usare in test/integration o
  /// teardown controllato, non durante la navigazione normale dell’app.
  Future<void> dispose() async {
    await Hive.close();
  }
}
