import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../layout/breakpoints.dart';
import '../../../viewmodels/home_shell_tab_controller.dart';
import '../../../viewmodels/onboarding_view_model.dart';
import '../../../../utils/onboarding_strings.dart';
import '../tour/tour_keys.dart';
import 'help_badge.dart';
import 'help_tooltip.dart';

/// FAB globale aiuto: tap = suggerimenti, long press = tour on-demand.
class QuickHelpFab extends StatelessWidget {
  const QuickHelpFab({super.key});

  void _showHelpSheet(BuildContext context, OnboardingViewModel vm) {
    final lang = vm.settings.preferredLanguage;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tourLine('help.quickTitle', lang),
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(tourLine('help.quickBody', lang)),
                if (kIsWeb) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      vm.startTour();
                    },
                    child: Text(tourLine('help.webTour', lang)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OnboardingViewModel>();
    if (vm.showOnboardingOverlay) {
      return const SizedBox.shrink();
    }
    final lang = vm.settings.preferredLanguage;
    final mq = MediaQuery.of(context);
    final bottomInset = mq.padding.bottom;
    final wide = isWideWidth(mq.size.width);
    final tab = context.watch<HomeShellTabController>();
    // Inventario: FAB principali sono a destra → QuickHelp a sinistra.
    // Altre tab: QuickHelp a destra così non copre titoli/sezioni allineati a sinistra.
    final onInventory = tab.index == HomeShellTabController.tabInventory;
    final leftPad = wide ? 104.0 : 16.0;
    final sidePad = wide ? 24.0 : 16.0;
    final bottomPad = (wide ? 24.0 : 16.0 + kBottomNavigationBarHeight) +
        bottomInset;
    final tabHint = switch (tab.index) {
      HomeShellTabController.tabInventory => tourLine('tour.inventory.title', lang),
      HomeShellTabController.tabAnalytics => tourLine('tour.analytics.title', lang),
      HomeShellTabController.tabUtility => tourLine('tour.notifications.title', lang),
      _ => tourLine('help.quickTitle', lang),
    };

    return Positioned(
      left: onInventory ? leftPad : null,
      right: onInventory ? null : sidePad,
      bottom: bottomPad + 8,
      child: HelpTooltip(
        message: tabHint,
        child: HelpBadge(
          show: !vm.state.isCompleted,
          child: GestureDetector(
            onLongPress: () => vm.startTour(),
            child: FloatingActionButton.small(
              key: TourKeys.helpFab,
              heroTag: 'housekeep_quick_help',
              onPressed: () => _showHelpSheet(context, vm),
              child: const Icon(Icons.help_outline),
            ),
          ),
        ),
      ),
    );
  }
}
