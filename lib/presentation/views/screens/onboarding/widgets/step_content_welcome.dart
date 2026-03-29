import 'package:flutter/material.dart';

import '../../../../../config/onboarding_config.dart';
import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';
import 'lottie_animation_widget.dart';

class StepContentWelcome extends StatelessWidget {
  const StepContentWelcome({
    super.key,
    required this.lang,
    required this.showAnimation,
  });

  final LanguageCode lang;
  final bool showAnimation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          obString(OnboardingStep.welcome, 'title', lang),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          obString(OnboardingStep.welcome, 'body', lang),
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (showAnimation) ...[
          const SizedBox(height: 16),
          const LottieAnimationWidget(assetPath: OnboardingAssets.welcome),
        ],
      ],
    );
  }
}
