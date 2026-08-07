import 'package:flutter/physics.dart';

/// Centralized spring physics used throughout the MetaZone Motion Framework.
///
/// This class defines reusable motion profiles to ensure that all animations
/// across the application feel consistent and predictable.
///
/// It intentionally contains no animation logic or widget-specific behavior.
abstract final class MotionPhysics {
  MotionPhysics._();

  /// Soft ambient motion.
  static const SpringDescription gentle = SpringDescription(
    mass: 1.0,
    stiffness: 90.0,
    damping: 18.0,
  );

  /// Standard UI interactions.
  static const SpringDescription smooth = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 24.0,
  );

  /// Fast responsive interactions.
  static const SpringDescription snappy = SpringDescription(
    mass: 1.0,
    stiffness: 260.0,
    damping: 22.0,
  );

  /// Interactive motion with a light bounce.
  static const SpringDescription bouncy = SpringDescription(
    mass: 1.0,
    stiffness: 340.0,
    damping: 16.0,
  );

  /// Playful elastic movement.
  static const SpringDescription elastic = SpringDescription(
    mass: 1.0,
    stiffness: 420.0,
    damping: 12.0,
  );

  /// Floating surfaces.
  static const SpringDescription floating = SpringDescription(
    mass: 1.15,
    stiffness: 120.0,
    damping: 14.0,
  );

  /// Glass UI components.
  static const SpringDescription glass = SpringDescription(
    mass: 1.0,
    stiffness: 150.0,
    damping: 19.0,
  );

  /// Hero transitions.
  static const SpringDescription hero = SpringDescription(
    mass: 1.0,
    stiffness: 310.0,
    damping: 27.0,
  );

  /// Dialogs & Bottom Sheets.
  static const SpringDescription modal = SpringDescription(
    mass: 1.0,
    stiffness: 240.0,
    damping: 23.0,
  );

  /// Navigation drawers.
  static const SpringDescription drawer = SpringDescription(
    mass: 1.0,
    stiffness: 205.0,
    damping: 21.0,
  );

  /// AR object movement.
  static const SpringDescription ar = SpringDescription(
    mass: 1.3,
    stiffness: 170.0,
    damping: 20.0,
  );

  /// Default tolerance.
  static const Tolerance standardTolerance = Tolerance(
    distance: 0.001,
    velocity: 0.001,
    time: 0.001,
  );

  /// High precision tolerance.
  static const Tolerance preciseTolerance = Tolerance(
    distance: 0.0001,
    velocity: 0.0001,
    time: 0.0001,
  );

  /// Lightweight tolerance.
  static const Tolerance relaxedTolerance = Tolerance(
    distance: 0.01,
    velocity: 0.01,
    time: 0.01,
  );

  static SpringDescription custom({
    required double mass,
    required double stiffness,
    required double damping,
  }) {
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }
}