import 'dart:ui';

import 'package:flutter/material.dart';

import 'semantic_colors.dart';

/// ===============================================================
/// MetaZone Spatial Glass Design System
/// Glass Engine v1
/// ===============================================================

abstract final class GlassSystem {
  GlassSystem._();

  // Blur

  static const double none = 0;

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double immersive = 48;

  // Opacity

  static const double ultraLight = .06;
  static const double light = .10;
  static const double medium = .16;
  static const double strong = .24;
  static const double heavy = .34;

  // Borders

  static const double borderThin = .5;
  static const double borderRegular = 1;
  static const double borderStrong = 1.5;

  // Radius

  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 24;
  static const double radiusXL = 32;
  static const double radiusInfinite = 999;

  // Decorations

  static BoxDecoration decoration({
    double opacity = medium,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius:
      borderRadius ??
          BorderRadius.circular(radiusLarge),
      border: Border.all(
        color: SemanticColors.glassBorder,
        width: borderRegular,
      ),
    );
  }

  static ImageFilter blur({
    double sigma = md,
  }) {
    return ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
    );
  }

  static List<BoxShadow> get shadows => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .20),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: .04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
}