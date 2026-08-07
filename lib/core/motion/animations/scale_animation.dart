import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class ScaleAnimation extends StatelessWidget {
  const ScaleAnimation({
    super.key,
    required this.child,
    this.show = true,
    this.begin = .92,
    this.end = 1.0,
    this.alignment = Alignment.center,
    this.preset = MotionPresets.normal,
    this.filterQuality,
    this.onEnd,
  });

  final Widget child;
  final bool show;
  final double begin;
  final double end;
  final Alignment alignment;
  final MotionPreset preset;
  final FilterQuality? filterQuality;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: show ? begin : end,
        end: show ? end : begin,
      ),
      duration: preset.duration,
      curve: preset.curve,
      onEnd: onEnd,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: alignment,
          filterQuality: filterQuality,
          child: child,
        );
      },
      child: child,
    );
  }
}