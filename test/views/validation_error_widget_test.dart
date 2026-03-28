import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/views/widgets/validation_error_widget.dart';

void main() {
  testWidgets('lista vuota non mostra nulla', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ValidationErrorWidget(messages: []),
        ),
      ),
    );
    expect(find.text('Correggi i campi'), findsNothing);
  });

  testWidgets('mostra messaggi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ValidationErrorWidget(messages: ['Errore uno', 'Errore due']),
        ),
      ),
    );
    expect(find.text('Correggi i campi'), findsOneWidget);
    expect(find.textContaining('Errore uno'), findsOneWidget);
    expect(find.textContaining('Errore due'), findsOneWidget);
  });
}
