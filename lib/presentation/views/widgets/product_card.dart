// ignore: unused_import
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/photo_storage_service.dart';
import '../../../core/theme/organized_hive_color_scheme.dart';
import '../../../domain/entities/product.dart';
import '../../../utils/date_formatting.dart';
import '../../theme/product_expiry_status.dart';
import 'product_expiry_labels.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
    this.onConsume,
    this.placementLine,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onConsume;

  /// Testo "Luogo: … · …" da [placementLineForProduct]; opzionale.
  final String? placementLine;

  Color _accentBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (product.isLowStock &&
        product.quantitaRimasta > 0 &&
        urgencyOf(product) != ExpiryUrgency.expired) {
      return OrganizedHiveColors.amberAccent;
    }
    final u = urgencyOf(product);
    return switch (u) {
      ExpiryUrgency.expired => scheme.error,
      ExpiryUrgency.urgent => scheme.error,
      ExpiryUrgency.ok => scheme.tertiary,
      ExpiryUrgency.unknown => scheme.outlineVariant,
    };
  }

  ({String text, Color fg, Color bg}) _chipStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (product.isExpired) {
      return (text: 'Scaduto', fg: scheme.onError, bg: scheme.error);
    }
    final d = product.daysUntilExpiry;
    if (d != null && d >= 0 && d <= 1) {
      return (
        text: 'Domani',
        fg: scheme.error,
        bg: scheme.errorContainer,
      );
    }
    if (d != null && d >= 2 && d <= 7) {
      return (
        text: 'In scadenza',
        fg: scheme.error,
        bg: scheme.errorContainer,
      );
    }
    if (product.isLowStock && product.quantitaRimasta > 0) {
      return (
        text: 'Basso stock',
        fg: OrganizedHiveColors.amberDark,
        bg: const Color(0xFFFEF3C7),
      );
    }
    if (product.dataScadenza != null) {
      final dt = product.dataScadenza!;
      final label =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      return (
        text: label,
        fg: scheme.tertiary,
        bg: scheme.tertiaryContainer.withValues(alpha: 0.12),
      );
    }
    return (
      text: 'N/D',
      fg: scheme.onSurfaceVariant,
      bg: scheme.surfaceContainer,
    );
  }

  Color _progressColor(BuildContext context) {
    if (product.isExpired) return Theme.of(context).colorScheme.error;
    if (product.isLowStock && product.quantitaRimasta > 0) {
      return OrganizedHiveColors.amberAccent;
    }
    return Theme.of(context).colorScheme.primary;
  }

  String _quantityCaption() {
    return 'Quantità: ${product.quantitaRimasta} / ${product.quantitaTotale}';
  }

  String _progressRightLabel() {
    if (product.isExpired) return 'Getta via';
    if (product.quantitaTotale <= 0) return '—';
    final pct =
        (product.quantitaRimasta / product.quantitaTotale * 100).round();
    if (product.isLowStock && product.quantitaRimasta > 0) {
      return 'Acquista';
    }
    return '$pct%';
  }

  double _progressValue() {
    if (product.quantitaTotale <= 0) return 0;
    return (product.quantitaRimasta / product.quantitaTotale).clamp(0.0, 1.0);
  }

  Widget _thumb(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rel = product.imageRelativePath;
    if (!kIsWeb && rel != null) {
      try {
        final photo = Provider.of<PhotoStorageService>(context, listen: false);
        final file = photo.resolveFile(rel);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              file,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbPlaceholder(scheme),
            ),
          );
        }
      } catch (_) {}
    }
    return _thumbPlaceholder(scheme);
  }

  Widget _thumbPlaceholder(ColorScheme scheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = _accentBar(context);
    final chip = _chipStyle(context);
    final grayscale = product.isExpired;
    Widget thumb = _thumb(context);
    if (grayscale) {
      thumb = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: thumb,
      );
    }

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                thumb,
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: chip.bg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          chip.text.toUpperCase(),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: chip.fg,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product.nome,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Scadenza: ${formatDate(product.dataScadenza)}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        expiryLineForList(product),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (placementLine != null) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                placementLine!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (onConsume != null)
                            IconButton(
                              icon: const Icon(Icons.restaurant_outlined),
                              onPressed: onConsume,
                              tooltip: 'Registra consumo',
                              color: scheme.tertiary,
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: onDelete,
                              tooltip: 'Elimina',
                              color: scheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _quantityCaption(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _progressRightLabel(),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: product.isExpired
                                  ? scheme.error
                                  : scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progressValue(),
                          minHeight: 8,
                          backgroundColor: scheme.surfaceContainer,
                          color: _progressColor(context),
                        ),
                      ),
                    ],
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
