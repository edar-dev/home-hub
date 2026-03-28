import 'package:flutter/material.dart';

import '../../presentation/theme/product_expiry_status.dart';

/// Colori bordo/evidenziazione scadenza coerenti con light/dark.
abstract final class AppExpiryColors {
  static Color borderColor(BuildContext context, ExpiryUrgency urgency) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (urgency) {
      ExpiryUrgency.expired => scheme.error,
      ExpiryUrgency.urgent =>
        dark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
      ExpiryUrgency.ok => scheme.primary,
      ExpiryUrgency.unknown => scheme.outlineVariant,
    };
  }
}
