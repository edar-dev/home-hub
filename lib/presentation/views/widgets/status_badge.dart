import 'package:flutter/material.dart';

import '../../theme/product_expiry_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.urgency,
    this.compact = false,
  });

  final ExpiryUrgency urgency;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (Color bg, Color fg, String label) = switch (urgency) {
      ExpiryUrgency.expired => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          'Scaduto',
        ),
      ExpiryUrgency.urgent => (
          dark ? const Color(0xFF5D4037) : const Color(0xFFFFE0B2),
          dark ? const Color(0xFFFFCC80) : const Color(0xFFE65100),
          'Urgente',
        ),
      ExpiryUrgency.ok => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          'OK',
        ),
      ExpiryUrgency.unknown => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          'Senza scadenza',
        ),
    };

    return Chip(
      label: Text(label),
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
      backgroundColor: bg,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg),
      padding: compact ? null : const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
