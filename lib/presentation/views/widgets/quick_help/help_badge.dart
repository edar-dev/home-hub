import 'package:flutter/material.dart';

/// Badge opzionale sul pulsante aiuto (es. onboarding incompleto).
class HelpBadge extends StatelessWidget {
  const HelpBadge({
    super.key,
    required this.show,
    required this.child,
  });

  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Badge(
      label: const Text('!'),
      child: child,
    );
  }
}
