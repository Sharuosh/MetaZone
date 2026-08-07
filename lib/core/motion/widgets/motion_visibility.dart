import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionVisibility extends StatelessWidget {
  const MotionVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.replacement = const SizedBox.shrink(),
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
    this.duration,
    this.curve,
  });

  final bool visible;

  final Widget child;

  final Widget replacement;

  final bool maintainState;

  final bool maintainAnimation;

  final bool maintainSize;

  final bool maintainSemantics;

  final bool maintainInteractivity;

  final Duration? duration;

  final Curve? curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? MotionPresets.normal.duration,
      switchInCurve: curve ?? MotionPresets.normal.curve,
      switchOutCurve: curve ?? MotionPresets.normal.curve,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Visibility(
        key: ValueKey<bool>(visible),
        visible: visible,
        replacement: replacement,
        maintainState: maintainState,
        maintainAnimation: maintainAnimation,
        maintainSize: maintainSize,
        maintainSemantics: maintainSemantics,
        maintainInteractivity: maintainInteractivity,
        child: child,
      ),
    );
  }
}