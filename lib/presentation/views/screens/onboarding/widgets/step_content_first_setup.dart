import 'package:flutter/material.dart';

import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';

class StepContentFirstSetup extends StatelessWidget {
  const StepContentFirstSetup({
    super.key,
    required this.lang,
    required this.nameController,
  });

  final LanguageCode lang;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          obString(OnboardingStep.firstSetup, 'title', lang),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          obString(OnboardingStep.firstSetup, 'body', lang),
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: obString(OnboardingStep.firstSetup, 'hint', lang),
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
