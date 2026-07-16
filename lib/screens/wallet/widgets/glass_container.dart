// File: lib/screens/wallet/widgets/glass_container.dart
// MetaZone Wallet — Universal Glass Container (Neon Glassmorphism PRO)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart'; // For AppColors

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double opacity;
  final bool showBorder;
  final bool glow;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.opacity = 0.18,
    this.showBorder = true,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder
              ? Border.all(color: AppColors.border.withOpacity(.35))
              : null,
          boxShadow: glow
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.35),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ]
              : [],
        ),
        child: child,
      ),
    );
  }
}
