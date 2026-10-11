import 'package:flutter/material.dart';

import '../theme/ar_camera_theme.dart';

/// Visual AR targeting reticle for MetaZone AR Camera V1.
///
/// The reticle is presentation-only.
/// It does not perform hit testing or communicate directly with
/// ARCore / Unity / the native AR layer.
///
/// The parent decides which visual state should be displayed.
class ARReticle extends StatelessWidget {
  const ARReticle({
    super.key,
    this.state = ARReticleState.searching,
    this.size = ARCameraTheme.reticleSize,
    this.showLabel = false,
    this.label,
  });

  final ARReticleState state;

  final double size;

  final bool showLabel;

  final String? label;

  @override
  Widget build(BuildContext context) {
    final _ReticleStyle style = _ReticleStyle.fromState(state);

    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _OuterRing(
                  size: size,
                  color: style.color,
                  animated: state == ARReticleState.searching ||
                      state == ARReticleState.processing,
                ),

                _ReticleBrackets(
                  size: size,
                  color: style.color,
                  active: state == ARReticleState.ready,
                ),

                _CenterIndicator(
                  color: style.color,
                  state: state,
                ),
              ],
            ),
          ),

          if (showLabel && label != null) ...[
            const SizedBox(height: 10),
            _ReticleLabel(
              text: label!,
              color: style.color,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// STATES
// ============================================================

enum ARReticleState {
  searching,
  processing,
  ready,
  trackingLost,
}

// ============================================================
// STYLE
// ============================================================

class _ReticleStyle {
  const _ReticleStyle({
    required this.color,
  });

  final Color color;

  factory _ReticleStyle.fromState(ARReticleState state) {
    switch (state) {
      case ARReticleState.searching:
        return const _ReticleStyle(
          color: ARCameraTheme.textSecondary,
        );

      case ARReticleState.processing:
        return const _ReticleStyle(
          color: ARCameraTheme.primaryBright,
        );

      case ARReticleState.ready:
        return const _ReticleStyle(
          color: ARCameraTheme.success,
        );

      case ARReticleState.trackingLost:
        return const _ReticleStyle(
          color: ARCameraTheme.warning,
        );
    }
  }
}

// ============================================================
// OUTER RING
// ============================================================

class _OuterRing extends StatefulWidget {
  const _OuterRing({
    required this.size,
    required this.color,
    required this.animated,
  });

  final double size;
  final Color color;
  final bool animated;

  @override
  State<_OuterRing> createState() => _OuterRingState();
}

class _OuterRingState extends State<_OuterRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _OuterRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animated && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animated && _controller.isAnimating) {
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
      animation: _controller,
      builder: (context, child) {
        final double rotation =
            _controller.value * 2 * 3.141592653589793;

        return Transform.rotate(
          angle: rotation,
          child: child,
        );
      },
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _OuterRingPainter(
          color: widget.color,
        ),
      ),
    );
  }
}

class _OuterRingPainter extends CustomPainter {
  const _OuterRingPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final radius =
        (size.shortestSide / 2) -
            3;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double dashLength = 11;
    const double gapLength = 7;

    final circumference = 2 * 3.141592653589793 * radius;

    final int segmentCount =
    (circumference / (dashLength + gapLength)).floor();

    final double angleStep =
        2 * 3.141592653589793 / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      final double startAngle =
          i * angleStep;

      final double endAngle =
          startAngle +
              angleStep *
                  (dashLength / (dashLength + gapLength));

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OuterRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ============================================================
// BRACKETS
// ============================================================

class _ReticleBrackets extends StatelessWidget {
  const _ReticleBrackets({
    required this.size,
    required this.color,
    required this.active,
  });

  final double size;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final double bracketSize =
        size * 0.72;

    return AnimatedContainer(
      duration: ARCameraTheme.motionNormal,
      curve: ARCameraTheme.motionCurve,
      width: bracketSize,
      height: bracketSize,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: color,
            width: active ? 2.2 : 1.4,
          ),
          bottom: BorderSide(
            color: color,
            width: active ? 2.2 : 1.4,
          ),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: bracketSize * 0.42,
          height: bracketSize * 0.42,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withValues(
                  alpha: active ? 0.85 : 0.40,
                ),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CENTER INDICATOR
// ============================================================

class _CenterIndicator extends StatelessWidget {
  const _CenterIndicator({
    required this.color,
    required this.state,
  });

  final Color color;
  final ARReticleState state;

  @override
  Widget build(BuildContext context) {
    final bool ready =
        state == ARReticleState.ready;

    final bool lost =
        state == ARReticleState.trackingLost;

    final double dotSize =
    ready
        ? ARCameraTheme.reticleCenterDotSize + 2
        : ARCameraTheme.reticleCenterDotSize;

    return AnimatedContainer(
      duration: ARCameraTheme.motionFast,
      curve: ARCameraTheme.motionCurve,
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: lost
            ? Colors.transparent
            : color,
        shape: BoxShape.circle,
        border: lost
            ? Border.all(
          color: color,
          width: 1.4,
        )
            : null,
        boxShadow: [
          if (ready)
            BoxShadow(
              color: color.withValues(
                alpha: 0.55,
              ),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
    );
  }
}

// ============================================================
// LABEL
// ============================================================

class _ReticleLabel extends StatelessWidget {
  const _ReticleLabel({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: ARCameraTheme.motionFast,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(
          ARCameraTheme.radiusSmall,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ARCameraTheme.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}