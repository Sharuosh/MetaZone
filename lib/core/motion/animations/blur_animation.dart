import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class BlurAnimation extends StatelessWidget {
  const BlurAnimation({
    super.key,
    required this.child,
    this.show = true,
    this.beginSigma = 20,
    this.endSigma = 0,
    this.preset = MotionPresets.normal,
    this.onEnd,
  });

  final Widget child;
  final bool show;
  final double beginSigma;
  final double endSigma;
  final MotionPreset preset;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: show ? beginSigma : endSigma,
        end: show ? endSigma : beginSigma,
      ),
      duration: preset.duration,
      curve: preset.curve,
      onEnd: onEnd,
      builder: (context, sigma, child) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}