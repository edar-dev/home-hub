import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_providers.dart';
import 'services/onboarding_service.dart';

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

  final onboardingService = OnboardingService(
    repository: dependencies.onboardingRepository,
    productRepository: dependencies.productRepository,
    locationRepository: dependencies.locationRepository,
  );
  final showOnboarding = await onboardingService.shouldShowOnboarding();

  runApp(
    HousekeepApp(
      dependencies: dependencies,
      initialShowOnboarding: showOnboarding,
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await dependencies.onboardingRepository.touchLastAppOpen();
    } catch (e, st) {
      debugPrint('touchLastAppOpen (deferred): $e\n$st');
    }

    try {
      await dependencies.notificationRepository.initialize();
    } catch (e, st) {
      debugPrint('Notification bootstrap: $e\n$st');
    }

    try {
      final products = await dependencies.productRepository.getAll();
      await dependencies.notificationRepository.rescheduleAllForProducts(
        products,
      );
    } catch (e, st) {
      debugPrint('Notification reschedule (deferred): $e\n$st');
    }
  });
}
