import 'package:flutter/material.dart';

import '../motion_presets.dart';

enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

class SharedAxisRoute<T> extends PageRouteBuilder<T> {
  SharedAxisRoute({
    required Widget page,
    RouteSettings? settings,
    MotionPreset preset = MotionPresets.normal,
    SharedAxisTransitionType transitionType =
        SharedAxisTransitionType.horizontal,
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

      switch (transitionType) {
        case SharedAxisTransitionType.horizontal:
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );

        case SharedAxisTransitionType.vertical:
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );

        case SharedAxisTransitionType.scaled:
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.92,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          );
      }
    },
  );
}