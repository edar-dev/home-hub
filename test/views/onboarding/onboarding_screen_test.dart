import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/location.dart';
import 'package:housekeep/domain/entities/storage_position.dart';
import 'package:housekeep/domain/repositories/location_repository.dart';
import 'package:housekeep/presentation/viewmodels/home_shell_tab_controller.dart';
import 'package:housekeep/presentation/viewmodels/onboarding_view_model.dart';
import 'package:housekeep/presentation/views/screens/onboarding/onboarding_screen.dart';
import 'package:housekeep/services/onboarding_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import '../../support/stub_onboarding_repository.dart';

class _MockLocationRepo extends Mock implements LocationRepository {}

void main() {
  late _MockLocationRepo mockLoc;

  setUpAll(() {
    registerFallbackValue(const Location(id: 'fb', nome: 'fb'));
    registerFallbackValue(
      const StoragePosition(id: 'fb', nome: 'fb', locationId: 'fb'),
    );
  });

  setUp(() {
    mockLoc = _MockLocationRepo();
    when(() => mockLoc.getAllWithPositions()).thenAnswer((_) async => []);
    when(() => mockLoc.getLocationById(any())).thenAnswer((_) async => null);
    when(() => mockLoc.getLocationWithPositions(any())).thenAnswer((_) async => null);
    when(() => mockLoc.saveLocation(any())).thenAnswer((_) async {});
    when(() => mockLoc.deleteLocation(any())).thenAnswer((_) async {});
    when(() => mockLoc.savePosition(any())).thenAnswer((_) async {});
    when(() => mockLoc.deletePosition(any())).thenAnswer((_) async {});
  });

  testWidgets('OnboardingScreen mostra titolo welcome (IT Stitch)', (tester) async {
    final repo = StubOnboardingRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<LocationRepository>.value(value: mockLoc),
            ChangeNotifierProvider<HomeShellTabController>(
              create: (_) => HomeShellTabController(),
            ),
            ChangeNotifierProvider<OnboardingViewModel>(
              create: (_) => OnboardingViewModel(
                repository: repo,
                service: OnboardingService(repository: repo),
              ),
            ),
          ],
          child: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Benvenuto'), findsOneWidget);
    expect(find.textContaining('Inventario Casa'), findsOneWidget);
  });
}
