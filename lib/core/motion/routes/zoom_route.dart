import 'package:flutter/material.dart';

import '../motion_presets.dart';

class ZoomRoute<T> extends PageRouteBuilder<T> {
  ZoomRoute({
    required Widget page,
    RouteSettings? settings,
    MotionPreset preset = MotionPresets.normal,
    double beginScale = 0.92,
    bool opaque = true,
    bool fullscreenDialog = false,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) : super(
    settings: settings,
    opaque: opaque,
    fullscreenDialog: fullscreenDialog,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    transitionDuration: preset.duration,
    reverseTransitionDuration: preset.duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: beginScale,
            end: 1.0,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}