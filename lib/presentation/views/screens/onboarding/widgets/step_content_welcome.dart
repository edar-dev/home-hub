import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

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
    final titleBody = Column(
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
      ],
    );

    final intro = showAnimation
        ? PlayAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: titleBody,
          )
        : titleBody;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        intro,
        if (showAnimation) ...[
          const SizedBox(height: 16),
          const LottieAnimationWidget(assetPath: OnboardingAssets.welcome),
        ],
      ],
    );
  }
}
