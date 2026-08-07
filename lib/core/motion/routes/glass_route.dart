import 'dart:ui';

import 'package:flutter/material.dart';

import '../motion_presets.dart';

class GlassRoute<T> extends PageRouteBuilder<T> {
  GlassRoute({
    required Widget page,
    RouteSettings? settings,
    MotionPreset preset = MotionPresets.glass,
    this.blurSigma = 18,
    this.backgroundColor = const Color(0x33000000),
    bool opaque = false,
    bool fullscreenDialog = false,
    bool barrierDismissible = false,
    String? barrierLabel,
  }) : super(
    settings: settings,
    opaque: opaque,
    fullscreenDialog: fullscreenDialog,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.transparent,
    barrierLabel: barrierLabel,
    transitionDuration: preset.duration,
    reverseTransitionDuration: preset.duration,
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: curved,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: ColoredBox(
                color: backgroundColor,
              ),
            ),
          ),
          FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.96,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          ),
        ],
      );
    },
  );

  final double blurSigma;

  final Color backgroundColor;
}