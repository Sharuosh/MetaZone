import 'package:flutter/material.dart';

import '../motion_presets.dart';

class FadeRoute<T> extends PageRouteBuilder<T> {
  FadeRoute({
    required Widget page,
    RouteSettings? settings,
    MotionPreset preset = MotionPresets.normal,
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
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: preset.curve,
        ),
        child: child,
      );
    },
  );
}