import '../domain/entities/tour_step.dart';

/// Step del tour on-demand (dopo onboarding). [targetKey] opzionale per highlight.
final List<TourStep> kTourSteps = [
  const TourStep(
    id: 'help_fab',
    titleKey: 'tour.fab.title',
    descriptionKey: 'tour.fab.body',
    targetKey: 'helpFab',
  ),
  const TourStep(
    id: 'inventory',
    titleKey: 'tour.inventory.title',
    descriptionKey: 'tour.inventory.body',
  ),
  const TourStep(
    id: 'analytics',
    titleKey: 'tour.analytics.title',
    descriptionKey: 'tour.analytics.body',
  ),
  const TourStep(
    id: 'notifications',
    titleKey: 'tour.notifications.title',
    descriptionKey: 'tour.notifications.body',
  ),
];
