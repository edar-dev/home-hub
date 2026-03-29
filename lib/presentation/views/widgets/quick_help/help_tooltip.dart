import 'package:flutter/material.dart';

/// Tooltip accessibile per il pulsante aiuto.
class HelpTooltip extends StatelessWidget {
  const HelpTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: child,
    );
  }
}
