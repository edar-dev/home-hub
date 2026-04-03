import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';

/// Flusso end-to-end con Hive su path temporaneo.
///
/// Esegue con: `flutter test integration_test/app_test.dart` (VM di test, senza device).
/// Per `IntegrationTestWidgetsFlutterBinding` + device reale/desktop, abilitare
/// Developer Mode su Windows (symlink) e usare `flutter test -d windows`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory? hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('housekeep_int_');
  });

  tearDown(() async {
    await Hive.close();
    final d = hiveDir;
    if (d != null && await d.exists()) {
      await d.delete(recursive: true);
    }
    hiveDir = null;
  });

  testWidgets('FAB, salvataggio e lista; persistenza dopo Hive.close',
      (tester) async {
    final deps = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    await tester.pumpWidget(HousekeepApp(dependencies: deps));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const ValueKey<String>('fab-product')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextFormField).first, 'ProdottoE2E');
    await tester.tap(find.text('Aggiungi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('ProdottoE2E'), findsWidgets);

    await deps.hiveService.dispose();

    final deps2 = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    await tester.pumpWidget(HousekeepApp(dependencies: deps2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ProdottoE2E'), findsOneWidget);
  });

  testWidgets('Luoghi: salvataggio e persistenza dopo Hive.close',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    final deps = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    await tester.pumpWidget(HousekeepApp(dependencies: deps));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Luoghi'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('fab-location')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'CucinaE2E');
    await tester.tap(find.text('Aggiungi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CucinaE2E'), findsWidgets);

    await deps.hiveService.dispose();

    final deps2 = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    await tester.pumpWidget(HousekeepApp(dependencies: deps2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Luoghi'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CucinaE2E'), findsOneWidget);
  });
}
