import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint(details.exceptionAsString());
      debugPrint(details.stack?.toString() ?? '');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught: $error\n$stack');
      return true;
    };
  }
  final dependencies = await AppFactory.create();
  runApp(HousekeepApp(dependencies: dependencies));
}
