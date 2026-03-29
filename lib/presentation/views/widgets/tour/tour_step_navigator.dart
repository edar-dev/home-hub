import 'package:flutter/material.dart';

/// Pulsanti Avanti / Indietro / Salta per il tour overlay.
class TourStepNavigator extends StatelessWidget {
  const TourStepNavigator({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.backLabel,
    required this.nextLabel,
    required this.doneLabel,
    required this.skipLabel,
    required this.showBack,
    this.isLast = false,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String backLabel;
  final String nextLabel;
  final String doneLabel;
  final String skipLabel;
  final bool showBack;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          TextButton(onPressed: onBack, child: Text(backLabel))
        else
          const SizedBox(width: 8),
        const Spacer(),
        TextButton(onPressed: onSkip, child: Text(skipLabel)),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onNext,
          child: Text(isLast ? doneLabel : nextLabel),
        ),
      ],
    );
  }
}
