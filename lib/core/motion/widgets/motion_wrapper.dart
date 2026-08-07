import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionWrapper extends StatelessWidget {
  const MotionWrapper({
    super.key,
    required this.child,
    this.visible = true,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.alignment = Alignment.center,
    this.duration,
    this.curve,
    this.ignorePointerWhenHidden = true,
  });

  final Widget child;

  final bool visible;

  final double opacity;

  final double scale;

  final Offset offset;

  final Alignment alignment;

  final Duration? duration;

  final Curve? curve;

  final bool ignorePointerWhenHidden;

  @override
  Widget build(BuildContext context) {
    final animationDuration =
        duration ?? MotionPresets.normal.duration;

    final animationCurve =
        curve ?? MotionPresets.normal.curve;

    Widget current = child;

    current = AnimatedSlide(
      offset: visible ? offset : const Offset(0, .05),
      duration: animationDuration,
      curve: animationCurve,
      child: current,
    );

    current = AnimatedScale(
      scale: visible ? scale : scale * .96,
      duration: animationDuration,
      curve: animationCurve,
      alignment: alignment,
      child: current,
    );

    current = AnimatedOpacity(
      opacity: visible ? opacity : 0,
      duration: animationDuration,
      curve: animationCurve,
      child: current,
    );

    if (ignorePointerWhenHidden) {
      current = IgnorePointer(
        ignoring: !visible,
        child: current,
      );
    }

    return current;
  }
}