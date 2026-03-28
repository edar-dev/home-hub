import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/exceptions/product_exception.dart';
import 'models/product_hive_model.dart';

const String kProductsBoxName = 'products';

/// Inizializzazione Hive e apertura box prodotti.
class HiveService {
  Future<void> init() async {
    try {
      await Hive.initFlutter();
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
