/// Costanti centralizzate per onboarding / tour FASE 5.
abstract final class OnboardingConfig {
  /// Epoca feature: incrementare su major release che deve ri-mostrare onboarding (se abilitato).
  static const int featureEpoch = 5;

  /// Giorni di inattività per proporre di nuovo l’onboarding.
  static const int inactivityDaysThreshold = 30;

  /// Soglia “pochi prodotti” per setup incompleto.
  static const int minProductsForCompleteSetup = 2;
}

/// Percorsi asset Lottie onboarding.
abstract final class OnboardingAssets {
  static const welcome = 'assets/animations/welcome.json';
  static const productForm = 'assets/animations/product_form.json';
  static const scannerDemo = 'assets/animations/scanner_demo.json';
  static const locationsOrganize = 'assets/animations/locations_organize.json';
  static const analyticsCharts = 'assets/animations/analytics_charts.json';
  static const notificationAlert = 'assets/animations/notification_alert.json';
  static const confetti = 'assets/animations/confetti.json';
}
