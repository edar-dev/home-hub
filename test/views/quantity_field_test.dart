import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/views/widgets/quantity_field.dart';

void main() {
  testWidgets('QuantityField + incrementa', (tester) async {
    final controller = TextEditingController(text: '2');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuantityField(
            label: 'Q',
            controller: controller,
            min: 1,
            max: 10,
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(controller.text, '3');
  });
}
