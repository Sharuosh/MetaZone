import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class FadeAnimation extends StatelessWidget {
  const FadeAnimation({
    super.key,
    required this.child,
    this.show = true,
    this.preset = MotionPresets.normal,
    this.alwaysIncludeSemantics = false,
    this.onEnd,
  });

  final Widget child;
  final bool show;
  final MotionPreset preset;
  final bool alwaysIncludeSemantics;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: show ? 1 : 0,
      duration: preset.duration,
      curve: preset.curve,
      alwaysIncludeSemantics: alwaysIncludeSemantics,
      onEnd: onEnd,
      child: child,
    );
  }
}