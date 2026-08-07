import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class ShimmerAnimation extends StatefulWidget {
  const ShimmerAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool enabled;
  final Duration? duration;
  final Curve? curve;

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

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
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ShimmerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled == oldWidget.enabled) {
      return;
    }

    if (widget.enabled) {
      _controller.repeat(reverse: true);
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
        final opacity = .75 + (_animation.value * .25);

        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }
}