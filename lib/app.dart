import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/services/photo_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'domain/repositories/analytics_repository.dart';
import 'domain/repositories/barcode_repository.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/onboarding_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/shopping_list_repository.dart';
import 'presentation/viewmodels/analytics_view_model.dart';
import 'presentation/viewmodels/location_inventory_view_model.dart';
import 'presentation/viewmodels/home_shell_tab_controller.dart';
import 'presentation/viewmodels/location_view_model.dart';
import 'presentation/viewmodels/notification_settings_view_model.dart';
import 'presentation/viewmodels/onboarding_view_model.dart';
import 'presentation/viewmodels/product_view_model.dart';
import 'presentation/viewmodels/shopping_list_view_model.dart';
import 'presentation/views/screens/home_shell_screen.dart';
import 'presentation/views/screens/onboarding/onboarding_screen.dart';
import 'presentation/views/widgets/quick_help/quick_help_fab.dart';
import 'presentation/views/widgets/tour/tour_overlay.dart';
import 'services/onboarding_service.dart';

class HousekeepApp extends StatelessWidget {
  const HousekeepApp({
    super.key,
    required this.dependencies,
    this.initialShowOnboarding = false,
  });

  final AppDependencies dependencies;

  /// Se true, mostra overlay onboarding al primo frame (valutato in [main]).
  final bool initialShowOnboarding;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: dependencies.hiveService),
        Provider<ProductRepository>.value(
          value: dependencies.productRepository,
        ),
        Provider<LocationRepository>.value(
          value: dependencies.locationRepository,
        ),
        Provider<AnalyticsRepository>.value(
          value: dependencies.analyticsRepository,
        ),
        Provider<BarcodeRepository>.value(
          value: dependencies.barcodeRepository,
        ),
        Provider<PhotoStorageService>.value(
          value: dependencies.photoStorage,
        ),
        Provider<NotificationRepository>.value(
          value: dependencies.notificationRepository,
        ),
        Provider<CategoryRepository>.value(
          value: dependencies.categoryRepository,
        ),
        Provider<ShoppingListRepository>.value(
          value: dependencies.shoppingListRepository,
        ),
        Provider<OnboardingRepository>.value(
          value: dependencies.onboardingRepository,
        ),
        ChangeNotifierProvider<OnboardingViewModel>(
          create: (context) => OnboardingViewModel(
            repository: dependencies.onboardingRepository,
            service: OnboardingService(
              repository: dependencies.onboardingRepository,
            ),
            initialShowOnboarding: initialShowOnboarding,
          ),
        ),
        ChangeNotifierProvider<HomeShellTabController>(
          create: (_) => HomeShellTabController(),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
            context.read<ProductRepository>(),
            context.read<LocationRepository>(),
            notificationRepository: context.read<NotificationRepository>(),
          ),
        ),
        ChangeNotifierProvider<NotificationSettingsViewModel>(
          create: (context) => NotificationSettingsViewModel(
            context.read<NotificationRepository>(),
            context.read<ProductRepository>(),
          ),
        ),
        ChangeNotifierProvider<ShoppingListViewModel>(
          create: (context) => ShoppingListViewModel(
            context.read<ShoppingListRepository>(),
          ),
        ),
        ChangeNotifierProvider<LocationInventoryViewModel>(
          create: (context) => LocationInventoryViewModel(
            context.read<ProductRepository>(),
            context.read<LocationRepository>(),
          ),
        ),
        ChangeNotifierProvider<LocationViewModel>(
          create: (context) =>
              LocationViewModel(context.read<LocationRepository>()),
        ),
        ChangeNotifierProvider<AnalyticsViewModel>(
          create: (context) => AnalyticsViewModel(
            context.read<AnalyticsRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Housekeep',
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
          Locale('en', 'US'),
        ],
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const _OnboardingGate(),
      ),
    );
  }
}

class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, vm, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            const HomeShellScreen(),
            if (vm.showOnboardingOverlay) const OnboardingScreen(),
            const QuickHelpFab(),
            if (vm.showTourOverlay && vm.tourStepCount > 0)
              TourOverlay(
                step: vm.currentTourStep,
                stepIndex: vm.tourStepIndex,
                totalSteps: vm.tourStepCount,
                language: vm.settings.preferredLanguage,
                onNext: () => vm.tourNext(),
                onBack: () => vm.tourBack(),
                onSkip: () => vm.dismissTour(),
              ),
          ],
        );
      },
    );
  }
}
