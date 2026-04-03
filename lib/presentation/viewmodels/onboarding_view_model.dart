import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../config/tour_config.dart';
import '../../domain/entities/onboarding_settings.dart';
import '../../domain/entities/onboarding_state.dart';
import '../../domain/entities/onboarding_step.dart';
import '../../domain/entities/tour_step.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../services/onboarding_service.dart';

/// ViewModel onboarding: stato UI, persistenza e trigger bootstrap.
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required OnboardingRepository repository,
    required OnboardingService service,
    bool initialShowOnboarding = false,
  })  : _repository = repository,
        _service = service,
        _showOnboardingOverlay = initialShowOnboarding {
    _loadState();
  }

  final OnboardingRepository _repository;
  final OnboardingService _service;

  OnboardingState _state = OnboardingState.initial;
  OnboardingSettings _settings = const OnboardingSettings();

  bool _showOnboardingOverlay;
  bool _isBusy = false;
  Timer? _notifyDebounce;

  OnboardingState get state => _state;
  OnboardingSettings get settings => _settings;

  /// Mostra overlay fullscreen onboarding.
  bool get showOnboardingOverlay => _showOnboardingOverlay;

  /// Tour on-demand (P3) o replay.
  bool get showTourOverlay => _showTourOverlay;
  bool _showTourOverlay = false;

  int _tourStepIndex = 0;

  /// Indice step nel tour on-demand.
  int get tourStepIndex => _tourStepIndex;

  int get tourStepCount => kTourSteps.length;

  TourStep get currentTourStep {
    if (kTourSteps.isEmpty) {
      throw StateError('kTourSteps vuoto');
    }
    final i = _tourStepIndex.clamp(0, kTourSteps.length - 1);
    return kTourSteps[i];
  }

  bool get isBusy => _isBusy;

  Future<void> _loadState() async {
    _isBusy = true;
    _notifyDebounced();
    try {
      _state = await _repository.getOnboardingState();
      _settings = await _repository.getSettings();
    } catch (e, st) {
      debugPrint('OnboardingViewModel._loadState: $e\n$st');
    } finally {
      _isBusy = false;
      _notifyDebounced();
    }
  }

  void _notifyDebounced() {
    _notifyDebounce?.cancel();
    _notifyDebounce = Timer(const Duration(milliseconds: 32), () {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    super.dispose();
  }

  /// Rivaluta se mostrare onboarding (es. dopo cambio impostazioni).
  Future<void> refreshShouldShowOnboarding() async {
    try {
      final show = await _service.shouldShowOnboarding();
      _showOnboardingOverlay = show;
      notifyListeners();
    } catch (e, st) {
      debugPrint('OnboardingViewModel.refreshShouldShowOnboarding: $e\n$st');
    }
  }

  void setShowOnboardingOverlay(bool value) {
    if (_showOnboardingOverlay == value) return;
    _showOnboardingOverlay = value;
    notifyListeners();
  }

  void requestTourOverlay({bool show = true}) {
    _showTourOverlay = show;
    notifyListeners();
  }

  /// Avvia tour on-demand (long press FAB o impostazioni).
  Future<void> startTour() async {
    if (kTourSteps.isEmpty) return;
    await _loadState();
    _tourStepIndex =
        (_state.tourResumeStepIndex ?? 0).clamp(0, kTourSteps.length - 1);
    _showTourOverlay = true;
    notifyListeners();
  }

  Future<void> tourNext() async {
    if (kTourSteps.isNotEmpty && _tourStepIndex < kTourSteps.length - 1) {
      _tourStepIndex++;
      final s = await _repository.getOnboardingState();
      await _repository.updateOnboardingState(
        s.copyWith(tourResumeStepIndex: _tourStepIndex),
      );
      await _loadState();
    } else {
      await dismissTour();
    }
    notifyListeners();
  }

  Future<void> tourBack() async {
    if (_tourStepIndex > 0) {
      _tourStepIndex--;
      final s = await _repository.getOnboardingState();
      await _repository.updateOnboardingState(
        s.copyWith(tourResumeStepIndex: _tourStepIndex),
      );
      await _loadState();
    }
    notifyListeners();
  }

  Future<void> dismissTour() async {
    _showTourOverlay = false;
    final s = await _repository.getOnboardingState();
    await _repository.updateOnboardingState(s.copyWith(clearTourResume: true));
    await _loadState();
    notifyListeners();
  }

  Future<void> replayTourFromSettings() async {
    final s = await _repository.getOnboardingState();
    await _repository.updateOnboardingState(
      s.copyWith(tourResumeStepIndex: 0),
    );
    _tourStepIndex = 0;
    await _loadState();
    _showTourOverlay = true;
    notifyListeners();
  }

  Future<void> updateState(OnboardingState state) async {
    _state = state;
    await _repository.updateOnboardingState(state);
    notifyListeners();
  }

  Future<void> markStepCompleted(OnboardingStep step) async {
    await _repository.markStepCompleted(step);
    await _loadState();
  }

  Future<void> completeOnboardingFlow() async {
    await _repository.completeOnboarding();
    _showOnboardingOverlay = false;
    await _loadState();
    notifyListeners();
  }

  Future<void> resetOnboardingForDebug() async {
    await _repository.resetOnboarding();
    await _loadState();
    notifyListeners();
  }

  Future<void> updateSettings(OnboardingSettings settings) async {
    _settings = settings;
    await _repository.updateSettings(settings);
    notifyListeners();
  }
}
