// File: lib/screens/wallet/earnings/earnings_chart.dart
// MetaZone Wallet — Neon Earnings Chart (2025 PRO Dashboard UI)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.card.withOpacity(.22),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.25),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _NeonChartPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _NeonChartPainter extends CustomPainter {
  final List<double> points = [
    3, 6, 5, 9, 7, 11, 14, 10, 12, 15, 13
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double spacing = size.width / (points.length - 1);

    // Smooth curve paint
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primarySoft,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Glow behind the line
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = AppColors.primarySoft.withOpacity(.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Dots paint
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    Path curvePath = Path();
    Path glowPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = spacing * i;
      final y = size.height - (points[i] / 15 * size.height);

      if (i == 0) {
        curvePath.moveTo(x, y);
        glowPath.moveTo(x, y);
      } else {
        final prevX = spacing * (i - 1);
        final prevY = size.height - (points[i - 1] / 15 * size.height);

        final ctrlX = (prevX + x) / 2;
        final ctrlY = (prevY + y) / 2;

        curvePath.quadraticBezierTo(ctrlX, prevY, x, y);
        glowPath.quadraticBezierTo(ctrlX, prevY, x, y);
      }
    }

    // Draw glow first
    canvas.drawPath(glowPath, glowPaint);

    // Draw main neon line
    canvas.drawPath(curvePath, linePaint);

    // Draw dots
    for (int i = 0; i < points.length; i++) {
      final x = spacing * i;
      final y = size.height - (points[i] / 15 * size.height);

      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
