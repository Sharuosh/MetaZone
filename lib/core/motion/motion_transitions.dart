import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

import 'motion_presets.dart';

/// ===========================================================================
///
///                     MetaZone Motion Transitions
///
/// ===========================================================================
///
/// Centralized transition definitions used by:
///
/// • Page Routes
/// • Motion Widgets
/// • Hero Animations
/// • Dialogs
/// • Bottom Sheets
///
/// ===========================================================================

abstract final class MotionTransitions {
  MotionTransitions._();

  //--------------------------------------------------------------------------
  // Fade
  //--------------------------------------------------------------------------

  static Animation<double> fade({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
  }) {
    return CurvedAnimation(
      parent: animation,
      curve: preset.curve,
    );
  }

  //--------------------------------------------------------------------------
  // Scale
  //--------------------------------------------------------------------------

  static Animation<double> scale({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
    double begin = .92,
    double end = 1,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Slide From Bottom
  //--------------------------------------------------------------------------

  static Animation<Offset> slideUp({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
    Offset begin = const Offset(0, .15),
    Offset end = Offset.zero,
  }) {
    return Tween(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Slide From Right
  //--------------------------------------------------------------------------

  static Animation<Offset> slideLeft({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
    Offset begin = const Offset(.15, 0),
    Offset end = Offset.zero,
  }) {
    return Tween(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Slide From Left
  //--------------------------------------------------------------------------

  static Animation<Offset> slideRight({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
    Offset begin = const Offset(-.15, 0),
    Offset end = Offset.zero,
  }) {
    return Tween(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Rotation
  //--------------------------------------------------------------------------

  static Animation<double> rotation({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
    double begin = -.04,
    double end = 0,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }

  //--------------------------------------------------------------------------
  // Opacity
  //--------------------------------------------------------------------------

  static Animation<double> opacity({
    required Animation<double> animation,
    MotionPreset preset = MotionPresets.normal,
  }) {
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: preset.curve,
      ),
    );
  }
}