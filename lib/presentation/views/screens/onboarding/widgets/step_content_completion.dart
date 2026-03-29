import 'package:flutter/material.dart';

import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';
import 'confetti_animation.dart';

class StepContentCompletion extends StatelessWidget {
  const StepContentCompletion({
    super.key,
    required this.lang,
    this.showConfetti = true,
  });

  final LanguageCode lang;
  final bool showConfetti;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showConfetti) const Positioned.fill(child: ConfettiAnimation()),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              obString(OnboardingStep.complete, 'title', lang),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              obString(OnboardingStep.complete, 'body', lang),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
