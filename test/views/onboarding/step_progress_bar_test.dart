import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/views/screens/onboarding/widgets/step_progress_bar.dart';

void main() {
  testWidgets('StepProgressBar mostra frazione', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StepProgressBar(
            currentIndex: 2,
            totalSteps: 8,
          ),
        ),
      ),
    );
    expect(find.text('3 / 8'), findsOneWidget);
  });
}
