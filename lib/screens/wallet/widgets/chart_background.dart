// File: lib/screens/wallet/widgets/chart_background.dart
// MetaZone Wallet — Neon Chart Background (PRO Grid Edition)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ChartBackground extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const ChartBackground({
    super.key,
    required this.child,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.18),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppColors.border.withOpacity(.3),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Neon Grid Painter
          Positioned.fill(child: CustomPaint(painter: _NeonGridPainter())),

          // Child chart (LineChart / BarChart / etc.)
          Padding(
            padding: const EdgeInsets.all(14),
            child: child,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Neon Grid Painter (Behind Chart)
// =============================================================
class _NeonGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(.06);

    const int rows = 8;
    const int cols = 8;

    final rowHeight = size.height / rows;
    final colWidth = size.width / cols;

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, rowHeight * i),
        Offset(size.width, rowHeight * i),
        paint,
      );
    }

    // Draw vertical lines
    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
        Offset(colWidth * i, 0),
        Offset(colWidth * i, size.height),
        paint,
      );
    }

    // Top glow gradient
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primarySoft.withOpacity(.25),
          Colors.transparent
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 40));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 40), glowPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
