import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionOpacity extends StatelessWidget {
  const MotionOpacity({
    super.key,
    required this.child,
    required this.opacity,
    this.duration,
    this.curve,
    this.alwaysIncludeSemantics = false,
    this.onEnd,
  });

  final Widget child;

  final double opacity;

  final Duration? duration;

  final Curve? curve;

  final bool alwaysIncludeSemantics;

  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity.clamp(0.0, 1.0),
      duration: duration ?? MotionPresets.normal.duration,
      curve: curve ?? MotionPresets.normal.curve,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      onEnd: onEnd,
      child: child,
    );
  }
}