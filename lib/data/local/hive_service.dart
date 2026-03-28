import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/exceptions/product_exception.dart';
import 'models/product_hive_model.dart';

const String kProductsBoxName = 'products';

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
}
