import 'package:flutter/material.dart';

/// Barra segmenti + Salta (prototipo Stitch, primo step).
class WelcomeProgressHeader extends StatelessWidget {
  const WelcomeProgressHeader({
    super.key,
    required this.filledCount,
    required this.totalSegments,
    required this.skipLabel,
    required this.onSkip,
  });

  final int filledCount;
  final int totalSegments;
  final String skipLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = totalSegments <= 0 ? 1 : totalSegments;
    final n = filledCount.clamp(0, t);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: List.generate(t, (i) {
              final filled = i < n;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: filled
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            skipLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
