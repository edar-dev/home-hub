import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Azioni tour: riproduci e reset debug.
class TourActionButtons extends StatelessWidget {
  const TourActionButtons({
    super.key,
    required this.onReplayTour,
    required this.onResetDebug,
    required this.replayLabel,
    required this.resetLabel,
  });

  final VoidCallback onReplayTour;
  final VoidCallback onResetDebug;
  final String replayLabel;
  final String resetLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.tonal(
          onPressed: onReplayTour,
          child: Text(replayLabel),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onResetDebug,
            child: Text(resetLabel),
          ),
        ],
      ],
    );
  }
}
