import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'services/product_storage_service.dart';
import 'viewmodels/product_view_model.dart';
import 'views/screens/product_list_screen.dart';

class HousekeepApp extends StatelessWidget {
  const HousekeepApp({super.key, required this.storage});

  final ProductStorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductStorageService>.value(value: storage),
        ChangeNotifierProvider<ProductViewModel>(
          create: (context) =>
              ProductViewModel(context.read<ProductStorageService>()),
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF81C784),
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const ProductListScreen(),
      ),
    );
  }
}
