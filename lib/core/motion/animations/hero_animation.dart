import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class HeroAnimation extends StatelessWidget {
  const HeroAnimation({
    super.key,
    required this.tag,
    required this.child,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = true,
    this.createRectTween,
    this.enabled = true,
    this.preset = MotionPresets.hero,
  });

  final Object tag;
  final Widget child;

  final bool enabled;

  final MotionPreset preset;

  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  final HeroPlaceholderBuilder? placeholderBuilder;

  final CreateRectTween? createRectTween;

  final bool transitionOnUserGestures;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Hero(
      tag: tag,
      createRectTween: createRectTween,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }
}