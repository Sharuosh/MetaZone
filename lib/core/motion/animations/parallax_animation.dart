import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class ParallaxAnimation extends StatelessWidget {
  const ParallaxAnimation({
    super.key,
    required this.child,
    required this.offset,
    this.multiplier = .15,
    this.alignment = Alignment.center,
    this.preset = MotionPresets.floating,
  });

  /// Child widget.
  final Widget child;

  /// Current scroll offset.
  final double offset;

  /// Parallax intensity.
  final double multiplier;

  /// Transform alignment.
  final Alignment alignment;

  final MotionPreset preset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        0,
        -(offset * multiplier),
      ),
      child: child,
    );
  }
}