import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/theme/product_expiry_status.dart';
import 'package:housekeep/presentation/views/widgets/status_badge.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('StatusBadge expired', (tester) async {
    await tester
        .pumpWidget(wrap(const StatusBadge(urgency: ExpiryUrgency.expired)));
    expect(find.text('Scaduto'), findsOneWidget);
  });

  testWidgets('StatusBadge urgent', (tester) async {
    await tester
        .pumpWidget(wrap(const StatusBadge(urgency: ExpiryUrgency.urgent)));
    expect(find.text('Urgente'), findsOneWidget);
  });

  testWidgets('StatusBadge ok', (tester) async {
    await tester.pumpWidget(wrap(const StatusBadge(urgency: ExpiryUrgency.ok)));
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('StatusBadge unknown', (tester) async {
    await tester
        .pumpWidget(wrap(const StatusBadge(urgency: ExpiryUrgency.unknown)));
    expect(find.text('Senza scadenza'), findsOneWidget);
  });
}
