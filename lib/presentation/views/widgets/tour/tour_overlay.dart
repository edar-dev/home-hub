import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/language_code.dart';
import '../../../../domain/entities/tour_step.dart';
import '../../../../utils/onboarding_strings.dart';
import '../../../viewmodels/home_shell_tab_controller.dart';
import 'tour_highlight.dart';
import 'tour_keys.dart';
import 'tour_step_navigator.dart';
import 'tour_tooltip.dart';

/// Overlay fullscreen tour: scrim, tooltip, navigazione step.
class TourOverlay extends StatefulWidget {
  const TourOverlay({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.language,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final TourStep step;
  final int stepIndex;
  final int totalSteps;
  final LanguageCode language;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  State<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends State<TourOverlay> {
  Rect? _hole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTab();
      _measure();
    });
  }

  @override
  void didUpdateWidget(covariant TourOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncTab();
        _measure();
      });
    }
  }

  void _syncTab() {
    if (!mounted) return;
    final tab = context.read<HomeShellTabController>();
    switch (widget.step.id) {
      case 'help_fab':
        tab.setIndex(HomeShellTabController.tabInventory);
        break;
      case 'inventory':
        tab.setIndex(HomeShellTabController.tabInventory);
        break;
      case 'analytics':
        tab.setIndex(HomeShellTabController.tabAnalytics);
        break;
      case 'notifications':
        tab.setIndex(HomeShellTabController.tabNotifications);
        break;
      default:
        break;
    }
  }

  void _measure() {
    final keyName = widget.step.targetKey;
    Rect? rect;
    if (keyName == 'helpFab') {
      rect = _rectForKey(TourKeys.helpFab);
    }
    if (rect == null && keyName != null) {
      debugPrint('TourOverlay: target "$keyName" non trovato, step senza buco.');
    }
    if (mounted) {
      setState(() => _hole = rect);
    }
  }

  Rect? _rectForKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final title = tourLine(widget.step.titleKey, lang);
    final body = tourLine(widget.step.descriptionKey, lang);
    final back = obCommon('back', lang);
    final next = obCommon('next', lang);
    final done = obCommon('finish', lang);
    final skip = obCommon('skip', lang);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TourHighlight(holeRect: _hole),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${widget.stepIndex + 1} / ${widget.totalSteps}',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TourTooltip(title: title, description: body),
                const SizedBox(height: 12),
                TourStepNavigator(
                  showBack: widget.stepIndex > 0,
                  isLast: widget.stepIndex >= widget.totalSteps - 1,
                  onBack: widget.onBack,
                  onNext: widget.onNext,
                  onSkip: widget.onSkip,
                  backLabel: back,
                  nextLabel: next,
                  doneLabel: done,
                  skipLabel: skip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
