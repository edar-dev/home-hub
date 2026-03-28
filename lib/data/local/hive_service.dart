import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/exceptions/location_exception.dart';
import '../../domain/exceptions/product_exception.dart';
import 'models/location_hive_model.dart';
import 'models/position_hive_model.dart';
import 'models/product_hive_model.dart';

const String kProductsBoxName = 'products';
const String kLocationsBoxName = 'locations';
const String kPositionsBoxName = 'positions';

/// Inizializzazione Hive e apertura box prodotti.
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
}
