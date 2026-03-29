import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';
import 'confetti_animation.dart';

class StepContentCompletion extends StatelessWidget {
  const StepContentCompletion({
    super.key,
    required this.lang,
    this.showConfetti = true,
    this.showAnimation = true,
  });

  final LanguageCode lang;
  final bool showConfetti;

  /// Animazione testo (simple_animations); indipendente da [showConfetti].
  final bool showAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = Column(
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
    );

    final animatedTexts = showAnimation
        ? PlayAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.92 + 0.08 * value,
                  child: child,
                ),
              );
            },
            child: texts,
          )
        : texts;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showConfetti) const Positioned.fill(child: ConfettiAnimation()),
        animatedTexts,
      ],
    );
  }
}
