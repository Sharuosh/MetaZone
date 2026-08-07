import 'package:flutter/widgets.dart';

import '../motion_presets.dart';

class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.enabled = true,
    this.minScale = .96,
    this.maxScale = 1.04,
    this.alignment = Alignment.center,
    this.duration,
    this.curve,
  });

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;
  final Alignment alignment;
  final Duration? duration;
  final Curve? curve;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
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

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? MotionPresets.floating.curve,
      ),
    );

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enabled == oldWidget.enabled) return;

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
        return Transform.scale(
          scale: _animation.value,
          alignment: widget.alignment,
          child: child,
        );
      },
    );
  }
}