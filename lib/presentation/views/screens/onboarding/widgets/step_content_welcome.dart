import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../../../../domain/entities/language_code.dart';
import '../../../../../domain/entities/onboarding_step.dart';
import '../../../../../utils/onboarding_strings.dart';

const _kWelcomeHeroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAgM0F9ZgUDQZzAp7EpUqbMaEeAgibYZ_4BlBGZRdLjbizoO6DyJSlYDHaDGlES3aqZlYHCUTR3ViaZ0o_ZqZyjMjHbkIlbbKz41e1ts-v71HHVLBl08WgUMXmaqVbXEUA_zVFjAJgIkhcla_Pc3CAIev_Zu7LKInXK2jEysi2e9Rn5objY76BH8PRpolyzbH1itUN4bYss9HuOOFbsc7fiU5Azj7TG3dfa85F3DfUPFKxZ88jG6RioY5OF5Vw9OQRi9puGIuskoLI';

/// Contenuto centrale del welcome: hero bento, titolo, testo, icone footer (Stitch).
class StepContentWelcome extends StatelessWidget {
  const StepContentWelcome({
    super.key,
    required this.lang,
    required this.showAnimation,
    this.useHeroPlaceholder = false,
  });

  final LanguageCode lang;
  final bool showAnimation;

  /// Se true (es. golden test), non usa [Image.network] per l’hero.
  final bool useHeroPlaceholder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.manrope(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: scheme.onSurface,
            ),
            children: [
              TextSpan(text: obString(OnboardingStep.welcome, 'titlePrefix', lang)),
              TextSpan(
                text: obString(OnboardingStep.welcome, 'titleBrand', lang),
                style: GoogleFonts.manrope(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          obString(OnboardingStep.welcome, 'body', lang),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    final animatedTitle = showAnimation
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
            child: titleBlock,
          )
        : titleBlock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WelcomeHero(
          scheme: scheme,
          isDark: isDark,
          lang: lang,
          usePlaceholder: useHeroPlaceholder,
        ),
        const SizedBox(height: 24),
        animatedTitle,
        const SizedBox(height: 32),
        _FooterRoomIcons(scheme: scheme),
      ],
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.scheme,
    required this.isDark,
    required this.lang,
    required this.usePlaceholder,
  });

  final ColorScheme scheme;
  final bool isDark;
  final LanguageCode lang;
  final bool usePlaceholder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 0.9,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Transform.rotate(
              angle: 0.21,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: scheme.tertiary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 36,
            left: 0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.secondaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: scheme.surfaceContainerLowest,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
                side: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.12),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      usePlaceholder
                          ? _HeroImageFallback(scheme: scheme)
                          : Image.network(
                              _kWelcomeHeroImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _HeroImageFallback(scheme: scheme),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _HeroImageFallback(scheme: scheme);
                              },
                            ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? scheme.surfaceContainerHigh
                                        .withValues(alpha: 0.72)
                                    : Colors.white.withValues(alpha: 0.82),
                                border: Border.all(
                                  color: isDark
                                      ? scheme.outlineVariant
                                          .withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: scheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.inventory_2_outlined,
                                        color: scheme.onPrimary,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            obString(
                                              OnboardingStep.welcome,
                                              'digitalCurator',
                                              lang,
                                            ).toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                              color: scheme.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            obString(
                                              OnboardingStep.welcome,
                                              'smartCatalog',
                                              lang,
                                            ),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerLow,
            scheme.surfaceContainer,
            scheme.primaryContainer.withValues(alpha: 0.25),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 72,
          color: scheme.primary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _FooterRoomIcons extends StatelessWidget {
  const _FooterRoomIcons({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final c = scheme.onSurfaceVariant.withValues(alpha: 0.3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.kitchen_outlined, color: c, size: 28),
        const SizedBox(width: 16),
        Icon(Icons.checkroom_outlined, color: c, size: 28),
        const SizedBox(width: 16),
        Icon(Icons.garage_outlined, color: c, size: 28),
        const SizedBox(width: 16),
        Icon(Icons.restaurant_outlined, color: c, size: 28),
      ],
    );
  }
}
