import 'package:flutter/material.dart';

/// Scrim scuro con “buco” opzionale sul target evidenziato.
class TourHighlight extends StatelessWidget {
  const TourHighlight({
    super.key,
    this.holeRect,
    this.padding = 8,
  });

  final Rect? holeRect;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TourHighlightPainter(
        holeRect: holeRect,
        padding: padding,
        color: Colors.black.withValues(alpha: 0.55),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TourHighlightPainter extends CustomPainter {
  _TourHighlightPainter({
    required this.holeRect,
    required this.padding,
    required this.color,
  });

  final Rect? holeRect;
  final double padding;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()..color = color;
    if (holeRect == null) {
      canvas.drawPath(full, paint);
      return;
    }
    final hole = holeRect!.inflate(padding);
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(hole, const Radius.circular(12)),
      );
    final overlay = Path.combine(PathOperation.difference, full, holePath);
    canvas.drawPath(overlay, paint);
  }

  @override
  bool shouldRepaint(covariant _TourHighlightPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect ||
        oldDelegate.color != color ||
        oldDelegate.padding != padding;
  }
}
