import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/di/app_providers.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/viewmodels/location_inventory_view_model.dart';
import 'presentation/viewmodels/location_view_model.dart';
import 'presentation/viewmodels/product_view_model.dart';
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
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) => ProductViewModel(
            context.read<ProductRepository>(),
            context.read<LocationRepository>(),
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
