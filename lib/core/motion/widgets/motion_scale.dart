import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionScale extends StatelessWidget {
  const MotionScale({
    super.key,
    required this.child,
    required this.scale,
    this.alignment = Alignment.center,
    this.filterQuality,
    this.duration,
    this.curve,
    this.onEnd,
  });

  final Widget child;

  final double scale;

  final Alignment alignment;

  final FilterQuality? filterQuality;

  final Duration? duration;

  final Curve? curve;

  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: scale,
      duration: duration ?? MotionPresets.normal.duration,
      curve: curve ?? MotionPresets.normal.curve,
      alignment: alignment,
      filterQuality: filterQuality,
      onEnd: onEnd,
      child: child,
    );
  }
}