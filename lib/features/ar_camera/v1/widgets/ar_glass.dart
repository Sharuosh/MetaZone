import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';

/// Reusable glass surface for MetaZone AR Camera V1.
///
/// Responsibilities:
/// - Glass background
/// - Backdrop blur
/// - Border
/// - Optional shadow
/// - Clipping
///
/// It intentionally contains NO navigation, AR logic, or business logic.
class ARGlass extends StatelessWidget {
  const ARGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(ARCameraTheme.radiusMedium),
    ),
    this.blur = ARCameraTheme.glassBlur,
    this.opacity = ARCameraTheme.glassOpacity,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
    this.enabled = true,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  final double? width;
  final double? height;

  final AlignmentGeometry? alignment;

  final BorderRadiusGeometry borderRadius;

  final double blur;
  final double opacity;

  final Color? backgroundColor;

  final Border? border;

  final List<BoxShadow>? boxShadow;

  final Clip clipBehavior;

  /// Allows temporarily disabling the glass blur while keeping the surface.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = opacity.clamp(0.0, 1.0);

    final effectiveBackground =
        backgroundColor ??
            ARCameraTheme.glassColor.withValues(
              alpha: effectiveOpacity,
            );

    Widget surface = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: borderRadius,
        border: border ??
            Border.all(
              color: ARCameraTheme.border,
              width: 1,
            ),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (!enabled || blur <= 0) {
      return ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: surface,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: surface,
      ),
    );
  }
}