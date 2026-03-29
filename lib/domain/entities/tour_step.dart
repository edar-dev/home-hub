import 'package:flutter/material.dart';

/// Definizione step tour on-demand (post-onboarding).
class TourStep {
  const TourStep({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    this.targetKey,
    this.tooltipAlignment = Alignment.bottomCenter,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String? targetKey;
  final Alignment tooltipAlignment;
}
