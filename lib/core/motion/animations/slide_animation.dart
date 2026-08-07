import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class SlideAnimation extends StatelessWidget {
  const SlideAnimation({
    super.key,
    required this.child,
    this.show = true,
    this.begin = const Offset(0, .15),
    this.end = Offset.zero,
    this.transformHitTests = true,
    this.preset = MotionPresets.normal,
    this.onEnd,
  });

  final Widget child;
  final bool show;
  final Offset begin;
  final Offset end;
  final bool transformHitTests;
  final MotionPreset preset;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(
        begin: show ? begin : end,
        end: show ? end : begin,
      ),
      duration: preset.duration,
      curve: preset.curve,
      onEnd: onEnd,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            value.dx * 100,
            value.dy * 100,
          ),
          transformHitTests: transformHitTests,
          child: child,
        );
      },
      child: child,
    );
  }
}