// ignore_for_file: avoid_print
//
// Genera un box Hive `products` con N prodotti sintetici in una directory temporanea o indicata.
//
// Uso: dart run tool/seed_performance_dataset.dart [count] [outputDir]
// Esempi:
//   dart run tool/seed_performance_dataset.dart 1500
//   dart run tool/seed_performance_dataset.dart 2000 D:/temp/hive_seed
//
// La directory viene creata se assente. L'app in esecuzione usa un altro path (path_provider).

import 'dart:io';

import 'package:hive/hive.dart';
import 'package:housekeep/data/local/models/product_hive_model.dart';
import 'package:uuid/uuid.dart';

/// Allineato a [kProductsBoxName] in `hive_service.dart` (box solo prodotti).
const String _productsBoxName = 'products';

Future<void> main(List<String> args) async {
  final count = args.isNotEmpty ? int.tryParse(args[0]) ?? 1000 : 1000;
  if (count < 1) {
    print('count deve essere >= 1');
    exitCode = 1;
    return;
  }

  final outDir = args.length > 1
      ? args[1]
      : Directory.systemTemp.createTempSync('housekeep_seed_').path;

  final dir = Directory(outDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  Hive.init(outDir);

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductHiveModelAdapter());
  }

  final box = await Hive.openBox<ProductHiveModel>(_productsBoxName);
  await box.clear();

  const uuid = Uuid();
  final now = DateTime.now();
  for (var i = 0; i < count; i++) {
    final id = uuid.v4();
    final nome = 'SeedProdotto_${i.toString().padLeft(5, '0')}';
    await box.put(
      id,
      ProductHiveModel(
        id: id,
        nome: nome,
        dataAcquistoMs: now.millisecondsSinceEpoch,
        dataScadenzaMs: i.isEven
            ? DateTime(now.year + 1, now.month, now.day).millisecondsSinceEpoch
            : null,
        quantitaTotale: 1 + (i % 10),
        quantitaRimasta: 1 + (i % 10),
        positionId: null,
        updatedAtMs: now.toUtc().millisecondsSinceEpoch,
        syncVersion: 0,
      ),
    );
  }

  await box.close();
  await Hive.close();

  print('Hive seed completato: $count prodotti in');
  print(outDir);
  print('Box: $_productsBoxName');
}
