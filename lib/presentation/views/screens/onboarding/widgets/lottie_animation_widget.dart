import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie lazy; fallback statico se asset mancante o errore caricamento.
class LottieAnimationWidget extends StatelessWidget {
  const LottieAnimationWidget({
    super.key,
    required this.assetPath,
    this.height = 180,
    this.repeat = true,
  });

  final String assetPath;
  final double height;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Icon(Icons.auto_awesome, size: 72),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Lottie.asset(
        assetPath,
        repeat: repeat,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.animation, size: 72),
        ),
      ),
    );
  }
}
