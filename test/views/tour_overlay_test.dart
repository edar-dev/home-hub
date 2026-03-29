import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/domain/entities/language_code.dart';
import 'package:housekeep/domain/entities/tour_step.dart';
import 'package:housekeep/presentation/viewmodels/home_shell_tab_controller.dart';
import 'package:housekeep/presentation/views/widgets/tour/tour_overlay.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('TourOverlay mostra tooltip', (tester) async {
    const step = TourStep(
      id: 't',
      titleKey: 'tour.fab.title',
      descriptionKey: 'tour.fab.body',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomeShellTabController>(
          create: (_) => HomeShellTabController(),
          child: Scaffold(
            body: TourOverlay(
              step: step,
              stepIndex: 0,
              totalSteps: 1,
              language: LanguageCode.it,
              onNext: () {},
              onBack: () {},
              onSkip: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(TourOverlay), findsOneWidget);
  });
}
