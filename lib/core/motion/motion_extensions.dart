import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/physics.dart';

import 'motion_physics.dart';
/// Common motion extensions used across the MetaZone Motion Framework.
extension MotionDurationExtensions on Duration {
  /// Multiplies a duration by a factor.
  Duration scale(double factor) {
    assert(factor >= 0);

    return Duration(
      microseconds: (inMicroseconds * factor).round(),
    );
  }

  /// Returns half the duration.
  Duration get half => scale(0.5);

  /// Returns double the duration.
  Duration get doubled => scale(2.0);

  /// Returns triple the duration.
  Duration get tripled => scale(3.0);

  /// Clamps the duration between [min] and [max].
  Duration clamp(
      Duration min,
      Duration max,
      ) {
    if (this < min) return min;
    if (this > max) return max;

    return this;
  }
}

/// Curve helpers.
extension MotionCurveExtensions on Curve {
  /// Creates a curved animation.
  CurvedAnimation animate(
      Animation<double> parent,
      ) {
    return CurvedAnimation(
      parent: parent,
      curve: this,
    );
  }

  /// Creates a curved animation with reverse curve.
  CurvedAnimation animateWithReverse(
      Animation<double> parent, {
        required Curve reverseCurve,
      }) {
    return CurvedAnimation(
      parent: parent,
      curve: this,
      reverseCurve: reverseCurve,
    );
  }
}

/// AnimationController helpers.
extension MotionControllerExtensions on AnimationController {
  /// Runs the animation forward from the beginning.
  TickerFuture restart() {
    value = 0;
    return forward();
  }

  /// Toggles between forward and reverse.
  TickerFuture toggle() {
    if (status == AnimationStatus.completed) {
      return reverse();
    }

    return forward();
  }

  /// Returns true if currently animating.
  bool get isAnimating =>
      status == AnimationStatus.forward ||
          status == AnimationStatus.reverse;

  /// Returns true if idle.
  bool get isIdle => !isAnimating;
}

/// Spring helpers.
extension MotionSpringExtensions on SpringDescription {
  /// Creates a spring simulation.
  SpringSimulation simulation({
    required double start,
    required double end,
    double velocity = 0,
    Tolerance tolerance = MotionPhysics.standardTolerance,
  }) {
    return SpringSimulation(
      this,
      start,
      end,
      velocity,
      tolerance: tolerance,
    );
  }
}

/// BuildContext helpers.
extension MotionContextExtensions on BuildContext {
  /// Returns whether animations should be disabled.
  bool get disableAnimations =>
      MediaQuery.maybeOf(this)?.disableAnimations ?? false;

  /// Returns the device pixel ratio.
  double get devicePixelRatio =>
      MediaQuery.devicePixelRatioOf(this);

  /// Returns the current text scale factor.
  double get textScale =>
      MediaQuery.textScalerOf(this).textScaleFactor;
}