import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

import 'motion_physics.dart';

/// ===========================================================================
///
///                        MetaZone Motion Presets
///
/// ===========================================================================
///
/// Reusable animation presets shared across the application.
///
/// Every animation widget inside the Motion Framework should use these presets
/// instead of manually specifying duration, curve and spring values.
///
/// ===========================================================================

final class MotionPreset {
  const MotionPreset({
    required this.duration,
    required this.curve,
    required this.spring,
  });

  final Duration duration;
  final Curve curve;
  final SpringDescription spring;
}

abstract final class MotionPresets {
  MotionPresets._();

  //--------------------------------------------------------------------------
  // Standard
  //--------------------------------------------------------------------------

  static const MotionPreset instant = MotionPreset(
    duration: Duration(milliseconds: 80),
    curve: Curves.linear,
    spring: MotionPhysics.snappy,
  );

  static const MotionPreset fast = MotionPreset(
    duration: Duration(milliseconds: 180),
    curve: Curves.easeOut,
    spring: MotionPhysics.snappy,
  );

  static const MotionPreset normal = MotionPreset(
    duration: Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.smooth,
  );

  static const MotionPreset slow = MotionPreset(
    duration: Duration(milliseconds: 420),
    curve: Curves.easeInOutCubic,
    spring: MotionPhysics.gentle,
  );

  //--------------------------------------------------------------------------
  // UI
  //--------------------------------------------------------------------------

  static const MotionPreset button = MotionPreset(
    duration: Duration(milliseconds: 140),
    curve: Curves.easeOut,
    spring: MotionPhysics.snappy,
  );

  static const MotionPreset card = MotionPreset(
    duration: Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.smooth,
  );

  static const MotionPreset listItem = MotionPreset(
    duration: Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.smooth,
  );

  static const MotionPreset dialog = MotionPreset(
    duration: Duration(milliseconds: 320),
    curve: Curves.easeOutBack,
    spring: MotionPhysics.modal,
  );

  static const MotionPreset bottomSheet = MotionPreset(
    duration: Duration(milliseconds: 340),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.modal,
  );

  static const MotionPreset drawer = MotionPreset(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.drawer,
  );

  //--------------------------------------------------------------------------
  // Premium
  //--------------------------------------------------------------------------

  static const MotionPreset glass = MotionPreset(
    duration: Duration(milliseconds: 260),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.glass,
  );

  static const MotionPreset floating = MotionPreset(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeInOutSine,
    spring: MotionPhysics.floating,
  );

  static const MotionPreset hero = MotionPreset(
    duration: Duration(milliseconds: 450),
    curve: Curves.easeInOutCubic,
    spring: MotionPhysics.hero,
  );

  //--------------------------------------------------------------------------
  // AR
  //--------------------------------------------------------------------------

  static const MotionPreset arPlacement = MotionPreset(
    duration: Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
    spring: MotionPhysics.ar,
  );

  static const MotionPreset arFocus = MotionPreset(
    duration: Duration(milliseconds: 260),
    curve: Curves.easeOut,
    spring: MotionPhysics.ar,
  );
}