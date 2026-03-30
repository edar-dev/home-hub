import 'package:flutter/material.dart';

/// Card metrica stile Stitch: angoli 24px, barra sinistra 4px, superficie bianca.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.leadingIcon,
    this.accentColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? leadingIcon;

  /// Colore barra verticale sinistra (default: primary).
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = accentColor ?? scheme.primary;
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final boundedGrid = h.isFinite && h > 0;
        final compact = boundedGrid && h < 160;
        final pad = compact ? 16.0 : 20.0;
        final iconSize = compact ? 26.0 : 28.0;

        final valueBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: compact ? 2 : 4),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: compact ? 11 : null,
                ),
              ),
            ],
          ],
        );

        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border(
              left: BorderSide(color: accent, width: 4),
            ),
          ),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: accent, size: iconSize),
                SizedBox(height: compact ? 6 : 8),
              ],
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (boundedGrid)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: valueBlock,
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                valueBlock,
              ],
            ],
          ),
        );
      },
    );
  }
}
