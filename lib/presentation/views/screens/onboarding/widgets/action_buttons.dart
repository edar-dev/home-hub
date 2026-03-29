import 'package:flutter/material.dart';

/// Pulsanti Avanti / Indietro / Salta per lo step corrente.
class OnboardingActionButtons extends StatelessWidget {
  const OnboardingActionButtons({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.primaryLabel,
    required this.backLabel,
    required this.skipLabel,
    this.showBack = true,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String primaryLabel;
  final String backLabel;
  final String skipLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (showBack)
              TextButton(onPressed: onBack, child: Text(backLabel))
            else
              const Spacer(),
            const Spacer(),
            FilledButton(
              onPressed: onNext,
              child: Text(primaryLabel),
            ),
          ],
        ),
        TextButton(onPressed: onSkip, child: Text(skipLabel)),
      ],
    );
  }
}
