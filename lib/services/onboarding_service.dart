import '../config/onboarding_config.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/onboarding_repository.dart';
import '../domain/repositories/product_repository.dart';

/// Regole di business per mostrare l’onboarding fullscreen.
class OnboardingService {
  OnboardingService({
    required OnboardingRepository repository,
    ProductRepository? productRepository,
    LocationRepository? locationRepository,
  })  : _repository = repository,
        _productRepository = productRepository,
        _locationRepository = locationRepository;

  final OnboardingRepository _repository;
  final ProductRepository? _productRepository;
  final LocationRepository? _locationRepository;

  bool get _canProbeInventory =>
      _productRepository != null && _locationRepository != null;

  /// True se va mostrato onboarding al bootstrap (prima schermata).
  Future<bool> shouldShowOnboarding() async {
    final settings = await _repository.getSettings();
    if (settings.skipOnboardingAutomatically) {
      return false;
    }

    final state = await _repository.getOnboardingState();

    // Primo avvio / flusso non completato
    if (!state.isCompleted) {
      return true;
    }

    // Major feature epoch (es. FASE 4 → 5): se possibile, solo se setup ancora “vuoto”.
    if (settings.showOnboardingOnUpdate &&
        state.lastPromptedFeatureEpoch < OnboardingConfig.featureEpoch) {
      if (!_canProbeInventory) {
        return true;
      }
      if (await _isSetupIncomplete()) {
        return true;
      }
    }

    // Inattività
    if (_isInactive(
        state.lastAppOpenDate, OnboardingConfig.inactivityDaysThreshold)) {
      return true;
    }

    return false;
  }

  /// Nessun luogo oppure meno di [OnboardingConfig.minProductsForCompleteSetup] prodotti.
  Future<bool> _isSetupIncomplete() async {
    final pr = _productRepository!;
    final lr = _locationRepository!;
    final locations = await lr.getAllWithPositions();
    if (locations.isEmpty) {
      return true;
    }
    final products = await pr.getAll();
    return products.length < OnboardingConfig.minProductsForCompleteSetup;
  }

  static bool _isInactive(DateTime? lastOpen, int daysThreshold) {
    if (lastOpen == null) return false;
    final now = DateTime.now();
    return now.difference(lastOpen) > Duration(days: daysThreshold);
  }
}
