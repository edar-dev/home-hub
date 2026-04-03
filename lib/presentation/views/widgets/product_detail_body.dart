import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import '../../../utils/date_formatting.dart';
import '../../theme/product_expiry_status.dart';
import 'product_expiry_labels.dart';
import 'status_badge.dart';

/// Contenuto dettaglio prodotto (riusabile in split view o schermata piena).
class ProductDetailBody extends StatelessWidget {
  const ProductDetailBody({
    super.key,
    required this.product,
    this.embedded = false,
    this.onEdit,
    this.onDelete,
    this.onConsume,
    this.placementLine,
  });

  final Product product;
  final bool embedded;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onConsume;

  /// Da [placementLineForProduct] (FASE 3).
  final String? placementLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgency = urgencyOf(product);
    final d = product.daysUntilExpiry;

    return SingleChildScrollView(
      padding: EdgeInsets.all(embedded ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                product.nome,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(urgency: urgency, compact: false),
              ),
              const SizedBox(height: 24),
              _InfoTile(
                icon: Icons.shopping_bag_outlined,
                label: 'Data acquisto',
                value: formatDate(product.dataAcquisto),
              ),
              _InfoTile(
                icon: Icons.event_outlined,
                label: 'Data scadenza',
                value: formatDate(product.dataScadenza),
              ),
              _InfoTile(
                icon: Icons.lock_open_outlined,
                label: 'Data apertura',
                value: formatDate(product.dataApertura),
              ),
              if (placementLine != null)
                _InfoTile(
                  icon: Icons.place_outlined,
                  label: 'Posizione',
                  value: placementLine!,
                ),
              const Divider(height: 32),
              Text(
                'Stato scadenza',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (product.dataScadenza == null)
                Text(
                  'Nessuna data di scadenza registrata.',
                  style: theme.textTheme.bodyLarge,
                )
              else if (product.isExpired)
                Text(
                  'Questo prodotto risulta scaduto.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              else if (d != null)
                Text(
                  d == 0 ? 'Scade oggi.' : 'Giorni alla scadenza: $d',
                  style: theme.textTheme.bodyLarge,
                ),
              const SizedBox(height: 16),
              Text(
                'Uso consigliato',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                recommendedUseHint(product),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(
                      Icons.scale,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'Rimasti ${product.quantitaRimasta} su ${product.quantitaTotale}',
                    ),
                  ),
                ],
              ),
              if (embedded &&
                  (onEdit != null ||
                      onDelete != null ||
                      onConsume != null)) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (onConsume != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onConsume,
                          icon: const Icon(Icons.restaurant_outlined),
                          label: const Text('Usa prodotto'),
                        ),
                      ),
                    if (onConsume != null &&
                        (onEdit != null || onDelete != null))
                      const SizedBox(width: 12),
                    if (onEdit != null)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifica'),
                        ),
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 12),
                    if (onDelete != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Elimina'),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
