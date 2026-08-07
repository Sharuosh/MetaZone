import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class MotionSwitcher extends StatelessWidget {
  const MotionSwitcher({
    super.key,
    required this.child,
    this.duration,
    this.curve,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
  });

  final Widget child;

  final Duration? duration;

  final Curve? curve;

  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? MotionPresets.normal.duration,
      switchInCurve: curve ?? MotionPresets.normal.curve,
      switchOutCurve: curve ?? MotionPresets.normal.curve,
      layoutBuilder: layoutBuilder,
      transitionBuilder: transitionBuilder,
      child: child,
    );
  }
}