import 'package:flutter/widgets.dart';
import '../motion_presets.dart';

class MotionSlide extends StatelessWidget {
  const MotionSlide({
    super.key,
    required this.child,
    required this.offset,
    this.duration,
    this.curve,
    this.onEnd,
  });

  final Widget child;

  final Offset offset;


  final Duration? duration;

  final Curve? curve;

  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: offset,
      duration: duration ?? MotionPresets.normal.duration,
      curve: curve ?? MotionPresets.normal.curve,
      onEnd: onEnd,
      child: child,
    );
  }
}