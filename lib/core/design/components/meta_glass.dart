import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

/// ===============================================================
/// MetaZone Glass Widget
/// Spatial Glass Design Language
/// ===============================================================

class MetaGlass extends StatelessWidget {
  const MetaGlass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.blur = 20,
    this.opacity = .12,
    this.gradient,
    this.border = true,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final double? width;
  final double? height;

  final double blur;
  final double opacity;

  final BorderRadius? borderRadius;

  final Gradient? gradient;

  final bool border;
  final bool shadow;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget glass = ClipRRect(
      borderRadius:
      borderRadius ??
          AppRadius.xxlRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: opacity,
            ),
            gradient: gradient,
            borderRadius:
            borderRadius ??
                AppRadius.xxlRadius,
            border: border
                ? Border.all(
              color: AppColors.glassBorder,
              width: 1,
            )
                : null,
            boxShadow:
            shadow
                ? AppShadows.glass
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) {
      return glass;
    }

    return InkWell(
      borderRadius:
      borderRadius ??
          AppRadius.xxlRadius,
      onTap: onTap,
      child: glass,
    );
  }
}