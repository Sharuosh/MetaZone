import 'package:flutter/material.dart';

/// Presentation configuration for MetaZone AR Camera V1.
///
/// This class does NOT replace the global MetaZone Design System.
/// It contains only AR-Camera-specific presentation values.
abstract final class ARCameraTheme {
  ARCameraTheme._();

  // ============================================================
  // AR CAMERA SURFACE
  // ============================================================

  static const Color cameraFallback = Color(0xFF050507);

  static const Color cameraScrim = Color(0x1A000000);

  // ============================================================
  // GLASS
  // ============================================================

  static const Color glassColor = Color(0x55101018);

  static const Color glassStrongColor = Color(0x99101018);

  static const Color glassSoftColor = Color(0x35101018);

  static const double glassBlur = 18.0;

  static const double glassBlurStrong = 24.0;

  static const double glassOpacity = 0.34;

  static const double glassStrongOpacity = 0.60;

  // ============================================================
  // AR ACCENT
  // ============================================================

  static const Color primary = Color(0xFF8B5CFF);

  static const Color primaryBright = Color(0xFFA97CFF);

  static const Color primarySoft = Color(0x338B5CFF);

  static const Color spatial = Color(0xFFBFA7FF);

  // ============================================================
  // TEXT
  // ============================================================

  static const Color textPrimary = Color(0xFFF7F5FF);

  static const Color textSecondary = Color(0xB8F7F5FF);

  static const Color textMuted = Color(0x73F7F5FF);

  // ============================================================
  // STATES
  // ============================================================

  static const Color success = Color(0xFF6FE7B7);

  static const Color warning = Color(0xFFFFC857);

  static const Color error = Color(0xFFFF6B81);

  // ============================================================
  // BORDERS
  // ============================================================

  static const Color border = Color(0x20FFFFFF);

  static const Color borderActive = Color(0x598B5CFF);

  // ============================================================
  // RADIUS
  // ============================================================

  static const double radiusSmall = 10.0;

  static const double radiusMedium = 14.0;

  static const double radiusLarge = 18.0;

  static const double radiusXLarge = 22.0;

  // ============================================================
  // MAIN CAMERA LAYOUT
  // ============================================================

  /// Slim top bar.
  static const double topBarHeight = 54.0;

  /// Slim bottom navigation.
  static const double bottomBarHeight = 32.0;

  /// Collapsed side rail.
  static const double sideRailWidth = 40.0;

  /// Expanded side rail.
  static const double sideRailExpandedWidth = 150.0;

  /// Main horizontal breathing room.
  static const double horizontalPadding = 12.0;

  static const double verticalPadding = 8.0;

  // ============================================================
  // ICON SIZES
  // ============================================================

  static const double iconSmall = 15.0;

  static const double iconMedium = 19.0;

  static const double iconLarge = 22.0;

  // ============================================================
  // TOUCH TARGETS
  // ============================================================

  /// Visual elements can be small while their interactive area
  /// remains comfortable.
  static const double minTouchTarget = 40.0;

  /// Collapsed rail control.
  static const double railButtonSize = 40.0;

  /// Central Create action.
  static const double createButtonSize = 50.0;

  // ============================================================
  // RETICLE
  // ============================================================

  static const double reticleSize = 54.0;

  static const double reticleRingSize = 48.0;

  static const double reticleCenterDotSize = 4.0;

  static const double reticleLineLength = 8.0;

  // ============================================================
  // MOTION
  // ============================================================

  static const Duration motionFast =
  Duration(milliseconds: 150);

  static const Duration motionNormal =
  Duration(milliseconds: 220);

  static const Duration motionSmooth =
  Duration(milliseconds: 300);

  static const Curve motionCurve =
      Curves.easeOutCubic;

  // ============================================================
  // SIDE RAIL
  // ============================================================

  static const Duration railAnimationDuration =
  Duration(milliseconds: 260);

  static const Curve railAnimationCurve =
      Curves.easeOutCubic;

  // ============================================================
  // SAFE SPACING
  // ============================================================

  static const double topSafeSpacing = 8.0;

  static const double bottomSafeSpacing = 12.0;
}