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
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/shopping_list_repository.dart';
import 'presentation/viewmodels/analytics_view_model.dart';
import 'presentation/viewmodels/location_inventory_view_model.dart';
import 'presentation/viewmodels/location_view_model.dart';
import 'presentation/viewmodels/notification_settings_view_model.dart';
import 'presentation/viewmodels/product_view_model.dart';
import 'presentation/viewmodels/shopping_list_view_model.dart';
import 'presentation/views/screens/home_shell_screen.dart';

class HousekeepApp extends StatelessWidget {
  const HousekeepApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

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
        home: const HomeShellScreen(),
      ),
    );
  }
}
