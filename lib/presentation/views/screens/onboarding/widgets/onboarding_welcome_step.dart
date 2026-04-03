import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';
import 'step_content_welcome.dart';
import 'welcome_progress_header.dart';

/// Primo step onboarding: layout allineato al prototipo Stitch (header, hero, CTA).
class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({
    super.key,
    required this.lang,
    required this.showAnimation,
    required this.onSkip,
    required this.onStart,
    required this.onSecondary,
    this.totalSegments = 8,
    this.useHeroPlaceholder = false,
  });

  final LanguageCode lang;
  final bool showAnimation;
  final VoidCallback onSkip;
  final VoidCallback onStart;
  final VoidCallback onSecondary;
  final int totalSegments;

  /// Vedi [StepContentWelcome.useHeroPlaceholder].
  final bool useHeroPlaceholder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final startLabel = obString(OnboardingStep.welcome, 'startNow', lang);
    final secondaryLabel = obString(OnboardingStep.welcome, 'secondary', lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WelcomeProgressHeader(
          filledCount: 1,
          totalSegments: totalSegments,
          skipLabel: obCommon('skip', lang),
          onSkip: onSkip,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 8),
            child: StepContentWelcome(
              lang: lang,
              showAnimation: showAnimation,
              useHeroPlaceholder: useHeroPlaceholder,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _WelcomeGradientCta(
          label: startLabel,
          onPressed: onStart,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onSecondary,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.surfaceContainerHigh,
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(
              secondaryLabel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeGradientCta extends StatelessWidget {
  const _WelcomeGradientCta({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                scheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: scheme.onPrimary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
