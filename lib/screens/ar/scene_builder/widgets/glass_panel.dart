// File: lib/screens/ar/scene_builder/widgets/glass_panel.dart
// MetaZone – Glass Panel Widget (Ultra PRO 2025)
// Global glassmorphism container used across Scene Builder & Editors

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blur = 18,
    this.opacity = .22,
    this.gradient,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.card.withOpacity(opacity),
                    AppColors.card.withOpacity(opacity * 0.7),
                  ],
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.border.withOpacity(.35),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primarySoft.withOpacity(.12),
                blurRadius: 20,
                spreadRadius: 1,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
