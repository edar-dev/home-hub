import 'package:flutter/material.dart';

import '../../../../../domain/entities/language_code.dart';

/// Lingua contenuti tour / onboarding.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LanguageCode value;
  final ValueChanged<LanguageCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lingua',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        DropdownButton<LanguageCode>(
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: LanguageCode.it, child: Text('Italiano')),
            DropdownMenuItem(value: LanguageCode.en, child: Text('English')),
            DropdownMenuItem(value: LanguageCode.es, child: Text('Español')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
