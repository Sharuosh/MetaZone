import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class RotateAnimation extends StatelessWidget {
  const RotateAnimation({
    super.key,
    required this.child,
    this.show = true,
    this.begin = -.08,
    this.end = 0,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.preset = MotionPresets.normal,
    this.onEnd,
  });

  final Widget child;
  final bool show;
  final double begin;
  final double end;
  final Alignment alignment;
  final FilterQuality? filterQuality;
  final MotionPreset preset;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: show ? begin : end,
        end: show ? end : begin,
      ),
      duration: preset.duration,
      curve: preset.curve,
      onEnd: onEnd,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * math.pi,
          alignment: alignment,
          filterQuality: filterQuality,
          child: child,
        );
      },
      child: child,
    );
  }
}