import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Breve overlay confetti (Lottie) al completamento onboarding.
class ConfettiAnimation extends StatelessWidget {
  const ConfettiAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Lottie.asset(
        'assets/animations/confetti.json',
        repeat: false,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
