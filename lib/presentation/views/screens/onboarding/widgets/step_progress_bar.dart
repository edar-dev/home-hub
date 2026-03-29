import 'package:flutter/material.dart';

import '../../../../../domain/entities/onboarding_step.dart';

/// Indicatore lineare + punti per 8 step.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
  });

  final int currentIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = totalSteps <= 0 ? 1 : totalSteps;
    final progress = (currentIndex + 1) / t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${currentIndex + 1} / $totalSteps',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            OnboardingStep.values.length,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                Icons.circle,
                size: i == currentIndex ? 12 : 8,
                color: i <= currentIndex
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
