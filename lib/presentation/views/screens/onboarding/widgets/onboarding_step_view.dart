import 'package:flutter/material.dart';

/// Contenitore scrollabile per il contenuto di uno step.
class OnboardingStepView extends StatelessWidget {
  const OnboardingStepView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: child,
    );
  }
}
