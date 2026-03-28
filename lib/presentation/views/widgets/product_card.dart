import 'package:flutter/material.dart';

import '../../../core/theme/app_expiry_colors.dart';
import '../../../domain/entities/product.dart';
import '../../../utils/date_formatting.dart';
import '../../theme/product_expiry_status.dart';
import 'product_expiry_labels.dart';
import 'status_badge.dart';

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
    final urgency = urgencyOf(product);
    final accent = AppExpiryColors.borderColor(context, urgency);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nome,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Scadenza: ${formatDate(product.dataScadenza)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    expiryLineForList(product),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(urgency: urgency, compact: true),
                            if (onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: onDelete,
                                tooltip: 'Elimina',
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Quantità: ${product.quantitaRimasta} / ${product.quantitaTotale}',
                              style: theme.textTheme.labelLarge,
                            ),
                            if (product.isLowStock &&
                                product.quantitaRimasta > 0) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: const Text('Poca scorta'),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                labelStyle: theme.textTheme.labelSmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
