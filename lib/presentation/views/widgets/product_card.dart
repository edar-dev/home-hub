import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import '../../../utils/date_formatting.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[
      Chip(
        label: Text(
          '${product.quantitaRimasta} / ${product.quantitaTotale}',
        ),
        visualDensity: VisualDensity.compact,
      ),
    ];

    if (product.isExpired) {
      chips.add(
        Chip(
          label: const Text('Scaduto'),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.colorScheme.errorContainer,
        ),
      );
    } else {
      final d = product.daysUntilExpiry;
      if (d != null && d >= 0 && d <= 7) {
        chips.add(
          Chip(
            label: Text(d == 0 ? 'Scade oggi' : 'Tra $d gg'),
            visualDensity: VisualDensity.compact,
          ),
        );
      }
    }

    if (product.isLowStock && product.quantitaRimasta > 0) {
      chips.add(
        Chip(
          label: const Text('Poca scorta'),
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Elimina',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: chips,
              ),
              const SizedBox(height: 8),
              _DateRow(
                label: 'Acquisto',
                value: formatDate(product.dataAcquisto),
              ),
              _DateRow(
                label: 'Scadenza',
                value: formatDate(product.dataScadenza),
              ),
              _DateRow(
                label: 'Apertura',
                value: formatDate(product.dataApertura),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
