import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class FloatingAnimation extends StatefulWidget {
  const FloatingAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.amplitude = 8,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool enabled;

  /// Vertical movement in logical pixels.
  final double amplitude;

  final Duration? duration;
  final Curve? curve;

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? MotionPresets.floating.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? MotionPresets.floating.curve,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FloatingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enabled == widget.enabled) return;

    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        final dy =
            math.sin(_animation.value * math.pi * 2) * widget.amplitude;

        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
    );
  }
}