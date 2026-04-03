import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:housekeep/app.dart';
import 'package:housekeep/core/di/app_providers.dart';

/// Smoke bootstrap: [HousekeepApp] con Hive su directory temporanea e onboarding disattivato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Directory? hiveDir;

  setUp(() async {
    hiveDir = await Directory.systemTemp.createTemp('housekeep_onb_int_');
  });

  tearDown(() async {
    await Hive.close();
    final d = hiveDir;
    if (d != null && await d.exists()) {
      await d.delete(recursive: true);
    }
    hiveDir = null;
  });

  testWidgets('HousekeepApp si avvia con initialShowOnboarding false',
      (tester) async {
    final deps = await AppFactory.create(hiveStoragePath: hiveDir!.path);
    await tester.pumpWidget(
      HousekeepApp(
        dependencies: deps,
        initialShowOnboarding: false,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await deps.hiveService.dispose();
  });
}
