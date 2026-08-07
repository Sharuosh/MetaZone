import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionFade extends StatelessWidget {
  const MotionFade({
    super.key,
    required this.child,
    required this.visible,
    this.duration,
    this.curve,
    this.alwaysIncludeSemantics = false,
    this.onEnd,
  });

  final Widget child;

  final bool visible;

  final Duration? duration;

  final Curve? curve;

  final bool alwaysIncludeSemantics;

  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration ?? MotionPresets.normal.duration,
      curve: curve ?? MotionPresets.normal.curve,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      onEnd: onEnd,
      child: child,
    );
  }
}