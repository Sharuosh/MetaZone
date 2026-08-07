import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// ===============================================================
/// MetaZone Card
/// Spatial Glass Design
/// ===============================================================

class MetaCard extends StatelessWidget {
  const MetaCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.borderRadius,
    this.border = true,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  final double? width;
  final double? height;

  final Color? color;
  final Gradient? gradient;

  final BorderRadius? borderRadius;

  final bool border;
  final bool shadow;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        gradient: gradient,
        borderRadius:
        borderRadius ??
            AppRadius.xxlRadius,
        border: border
            ? Border.all(
          color: AppColors.border,
          width: 1,
        )
            : null,
        boxShadow:
        shadow
            ? AppShadows.md
            : null,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
        borderRadius ??
            AppRadius.xxlRadius,
        onTap: onTap,
        child: card,
      ),
    );
  }
}