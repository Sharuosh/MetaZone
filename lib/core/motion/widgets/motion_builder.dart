import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

typedef MotionChildBuilder = Widget Function(
    BuildContext context,
    Widget? child,
    );

class MotionBuilder extends StatelessWidget {
  const MotionBuilder({
    super.key,
    required this.builder,
    this.child,
    this.duration,
    this.curve,
    this.onEnd,
  });

  final MotionChildBuilder builder;

  final Widget? child;

  final Duration? duration;

  final Curve? curve;

  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: 0,
        end: 1,
      ),
      duration: duration ?? MotionPresets.normal.duration,
      curve: curve ?? MotionPresets.normal.curve,
      onEnd: onEnd,
      builder: (context, value, child) {
        return builder(context, child);
      },
      child: child,
    );
  }
}