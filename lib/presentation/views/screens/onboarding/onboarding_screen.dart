import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/language_code.dart';
import '../../../../domain/entities/location.dart';
import '../../../../domain/entities/onboarding_step.dart';
import '../../../../domain/repositories/location_repository.dart';
import '../../../viewmodels/home_shell_tab_controller.dart';
import '../../../viewmodels/onboarding_view_model.dart';
import '../barcode_scanner_screen.dart';
import '../product_form_screen.dart';
import '../../../../utils/onboarding_strings.dart';
import 'widgets/action_buttons.dart';
import 'widgets/onboarding_step_view.dart';
import 'widgets/step_content_add_product.dart';
import 'widgets/step_content_analytics.dart';
import 'widgets/step_content_completion.dart';
import 'widgets/step_content_first_setup.dart';
import 'widgets/step_content_locations.dart';
import 'widgets/step_content_notifications.dart';
import 'widgets/step_content_scanner.dart';
import 'widgets/step_content_welcome.dart';
import 'widgets/step_progress_bar.dart';

/// Flusso onboarding fullscreen: 8 step, swipe, CTA “Prova ora”.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _steps = OnboardingStep.values;
  final PageController _pageController = PageController();
  final TextEditingController _homeNameController = TextEditingController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _homeNameController.dispose();
    super.dispose();
  }

  LanguageCode _lang(OnboardingViewModel vm) =>
      vm.settings.preferredLanguage;

  Future<void> _markCurrent(OnboardingViewModel vm) async {
    await vm.markStepCompleted(_steps[_index]);
  }

  Future<void> _goNext(OnboardingViewModel vm) async {
    if (_index < _steps.length - 1) {
      await _markCurrent(vm);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _markCurrent(vm);
      await vm.completeOnboardingFlow();
    }
  }

  Future<void> _goBack() async {
    if (_index > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveFirstHomeIfNeeded(LocationRepository locations) async {
    final name = _homeNameController.text.trim();
    if (name.isEmpty) return;
    final existing = await locations.getAllWithPositions();
    if (existing.isNotEmpty) return;
    await locations.saveLocation(
      Location(id: const Uuid().v4(), nome: name),
    );
  }

  Future<void> _onPrimary(OnboardingViewModel vm) async {
    if (_steps[_index] == OnboardingStep.firstSetup) {
      final loc = context.read<LocationRepository>();
      await _saveFirstHomeIfNeeded(loc);
    }
    if (_steps[_index] == OnboardingStep.complete) {
      await vm.completeOnboardingFlow();
      return;
    }
    await _goNext(vm);
  }

  Future<void> _skipAll(OnboardingViewModel vm) async {
    await vm.completeOnboardingFlow();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    final lang = _lang(vm);
    final showAnim = vm.state.showAnimations &&
        !MediaQuery.disableAnimationsOf(context);
    final nextLabel = obCommon('next', lang);
    final backLabel = obCommon('back', lang);
    final skipLabel = obCommon('skip', lang);
    final tryLabel = obCommon('tryNow', lang);
    final finishLabel = obCommon('finish', lang);

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressBar(
                currentIndex: _index,
                totalSteps: _steps.length,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _steps.length,
                  itemBuilder: (context, i) {
                    final step = _steps[i];
                    return OnboardingStepView(
                      child: _buildStepBody(
                        context,
                        step,
                        lang,
                        showAnim,
                      ),
                    );
                  },
                ),
              ),
              _buildTryRow(context, vm, tryLabel),
              const SizedBox(height: 8),
              OnboardingActionButtons(
                showBack: _index > 0,
                onBack: _goBack,
                onNext: () => _onPrimary(vm),
                onSkip: () => _skipAll(vm),
                primaryLabel: _steps[_index] == OnboardingStep.complete
                    ? finishLabel
                    : nextLabel,
                backLabel: backLabel,
                skipLabel: skipLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody(
    BuildContext context,
    OnboardingStep step,
    LanguageCode lang,
    bool showAnim,
  ) {
    switch (step) {
      case OnboardingStep.welcome:
        return StepContentWelcome(lang: lang, showAnimation: showAnim);
      case OnboardingStep.addProduct:
        return StepContentAddProduct(lang: lang, showAnimation: showAnim);
      case OnboardingStep.scanner:
        return StepContentScanner(lang: lang, showAnimation: showAnim);
      case OnboardingStep.locations:
        return StepContentLocations(lang: lang, showAnimation: showAnim);
      case OnboardingStep.analytics:
        return StepContentAnalytics(lang: lang, showAnimation: showAnim);
      case OnboardingStep.notifications:
        return StepContentNotifications(lang: lang, showAnimation: showAnim);
      case OnboardingStep.firstSetup:
        return StepContentFirstSetup(
          lang: lang,
          nameController: _homeNameController,
        );
      case OnboardingStep.complete:
        return StepContentCompletion(
          lang: lang,
          showConfetti: showAnim,
        );
    }
  }

  Widget _buildTryRow(
    BuildContext context,
    OnboardingViewModel vm,
    String tryLabel,
  ) {
    final tab = context.read<HomeShellTabController>();
    final step = _steps[_index];
    VoidCallback? onTry;
    switch (step) {
      case OnboardingStep.addProduct:
        onTry = () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const ProductFormScreen(),
            ),
          );
        };
        break;
      case OnboardingStep.scanner:
        onTry = () async {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => const BarcodeScannerScreen(),
            ),
          );
        };
        break;
      case OnboardingStep.locations:
        onTry = () => tab.setIndex(HomeShellTabController.tabLocations);
        break;
      case OnboardingStep.analytics:
        onTry = () => tab.setIndex(HomeShellTabController.tabAnalytics);
        break;
      case OnboardingStep.notifications:
        onTry = () => tab.setIndex(HomeShellTabController.tabNotifications);
        break;
      default:
        onTry = null;
    }
    if (onTry == null) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: onTry,
      icon: const Icon(Icons.open_in_new),
      label: Text(tryLabel),
    );
  }
}
