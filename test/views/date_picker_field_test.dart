import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housekeep/presentation/views/widgets/date_picker_field.dart';

void main() {
  testWidgets('mostra label e placeholder data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it', 'IT')],
        home: Scaffold(
          body: DatePickerField(
            label: 'Data test',
            value: null,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Data test'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });
}
