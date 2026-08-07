import 'package:flutter/material.dart';

import '../motion_presets.dart';

class SlideRoute<T> extends PageRouteBuilder<T> {
  SlideRoute({
    required Widget page,
    RouteSettings? settings,
    MotionPreset preset = MotionPresets.normal,
    Offset begin = const Offset(0.15, 0),
    Offset end = Offset.zero,
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

      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: end,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      );
    },
  );
}