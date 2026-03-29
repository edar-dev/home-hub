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
  try {
    await dependencies.notificationRepository.initialize();
    final products = await dependencies.productRepository.getAll();
    await dependencies.notificationRepository.rescheduleAllForProducts(
      products,
    );
  } catch (e, st) {
    debugPrint('Notification bootstrap: $e\n$st');
  }
  runApp(HousekeepApp(dependencies: dependencies));
}
