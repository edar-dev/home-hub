import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/data/local/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HiveService con storagePath apre box prodotti', () async {
    final dir = await Directory.systemTemp.createTemp('hive_svc_');
    addTearDown(() async {
      await Hive.close();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    });

    final svc = HiveService(storagePath: dir.path);
    await svc.init();
    final box = await svc.openProductsBox();
    expect(box.name, kProductsBoxName);
    await box.close();
    await Hive.deleteBoxFromDisk(kProductsBoxName);
  });
}
