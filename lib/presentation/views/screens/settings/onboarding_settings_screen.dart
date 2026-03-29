import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/language_code.dart';
import '../../../viewmodels/onboarding_view_model.dart';
import '../../../../utils/onboarding_strings.dart';
import 'widgets/animation_speed_slider.dart';
import 'widgets/language_selector.dart';
import 'widgets/tour_action_buttons.dart';

/// Impostazioni onboarding, tour e aiuto.
class OnboardingSettingsScreen extends StatelessWidget {
  const OnboardingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, vm, _) {
        final lang = vm.settings.preferredLanguage;
        return Scaffold(
          appBar: AppBar(
            title: Text(tourLine('settings.title', lang)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text(tourLine('settings.skipAuto', lang)),
                subtitle: Text(tourLine('settings.skipAutoSubtitle', lang)),
                value: vm.settings.skipOnboardingAutomatically,
                onChanged: (v) => vm.updateSettings(
                  vm.settings.copyWith(skipOnboardingAutomatically: v),
                ),
              ),
              SwitchListTile(
                title: Text(tourLine('settings.showOnUpdate', lang)),
                value: vm.settings.showOnboardingOnUpdate,
                onChanged: (v) => vm.updateSettings(
                  vm.settings.copyWith(showOnboardingOnUpdate: v),
                ),
              ),
              const Divider(height: 32),
              Text(
                tourLine('settings.animationSpeed', lang),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              AnimationSpeedSlider(
                value: vm.settings.animationSpeed,
                onChanged: (s) => vm.updateSettings(
                  vm.settings.copyWith(animationSpeed: s),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tourLine('settings.language', lang),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              LanguageSelector(
                value: vm.settings.preferredLanguage,
                onChanged: (LanguageCode c) => vm.updateSettings(
                  vm.settings.copyWith(preferredLanguage: c),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La lingua si applica ai testi del tour e dell’onboarding.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Divider(height: 32),
              SwitchListTile(
                title: Text(tourLine('settings.tooltips', lang)),
                value: vm.settings.showContextualHelp,
                onChanged: (v) => vm.updateSettings(
                  vm.settings.copyWith(showContextualHelp: v),
                ),
              ),
              SwitchListTile(
                title: Text(tourLine('settings.analytics', lang)),
                value: vm.settings.enableAnalytics,
                onChanged: (v) => vm.updateSettings(
                  vm.settings.copyWith(enableAnalytics: v),
                ),
              ),
              const SizedBox(height: 16),
              TourActionButtons(
                replayLabel: tourLine('settings.replayTour', lang),
                resetLabel: tourLine('settings.resetDebug', lang),
                onReplayTour: () async {
                  final vm = context.read<OnboardingViewModel>();
                  Navigator.of(context).pop();
                  await Future<void>.delayed(Duration.zero);
                  await vm.replayTourFromSettings();
                },
                onResetDebug: () async {
                  await vm.resetOnboardingForDebug();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Onboarding reimpostato')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
