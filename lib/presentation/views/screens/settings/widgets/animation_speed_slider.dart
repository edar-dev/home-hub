import 'package:flutter/material.dart';

import '../../../../../domain/entities/animation_speed.dart';

/// Selettore velocità animazioni (lenta / normale / veloce).
class AnimationSpeedSlider extends StatelessWidget {
  const AnimationSpeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AnimationSpeed value;
  final ValueChanged<AnimationSpeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnimationSpeed>(
      segments: const [
        ButtonSegment(
          value: AnimationSpeed.slow,
          label: Text('Lenta'),
        ),
        ButtonSegment(
          value: AnimationSpeed.normal,
          label: Text('Normale'),
        ),
        ButtonSegment(
          value: AnimationSpeed.fast,
          label: Text('Veloce'),
        ),
      ],
      selected: {value},
      onSelectionChanged: (s) {
        if (s.isNotEmpty) onChanged(s.first);
      },
    );
  }
}
