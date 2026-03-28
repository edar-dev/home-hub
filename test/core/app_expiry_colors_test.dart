import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/core/theme/app_expiry_colors.dart';
import 'package:housekeep/presentation/theme/product_expiry_status.dart';

void main() {
  testWidgets('borderColor per ogni urgenza (light)', (tester) async {
    late Color c;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Builder(
          builder: (context) {
            c = AppExpiryColors.borderColor(context, ExpiryUrgency.ok);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(c, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) {
            expect(
              AppExpiryColors.borderColor(context, ExpiryUrgency.expired),
              isNotNull,
            );
            expect(
              AppExpiryColors.borderColor(context, ExpiryUrgency.urgent),
              isNotNull,
            );
            expect(
              AppExpiryColors.borderColor(context, ExpiryUrgency.unknown),
              isNotNull,
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
