import 'package:flutter/material.dart';

import 'app.dart';
import 'services/product_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await ProductStorageService.open();
  runApp(HousekeepApp(storage: storage));
}
