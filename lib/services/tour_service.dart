import '../config/tour_config.dart';
import '../domain/entities/tour_step.dart';

/// Metadati tour on-demand (nessuno stato UI: vive in [OnboardingViewModel]).
class TourService {
  List<TourStep> get steps => kTourSteps;

  int clampStepIndex(int index) {
    if (steps.isEmpty) return 0;
    if (index < 0) return 0;
    if (index >= steps.length) return steps.length - 1;
    return index;
  }
}
