import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppFactory.create();
  runApp(HousekeepApp(dependencies: dependencies));
}
