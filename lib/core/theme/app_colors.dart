import 'package:flutter/material.dart';

import '../design/foundation/semantic_colors.dart';

/// ===============================================================
/// MetaZone Theme Colors
/// Spatial Glass Design Language
/// ===============================================================
///
/// AppColors is the public color API used by the application UI.
///
/// SemanticColors remains the source of truth.
/// Compatibility aliases are kept here so older MetaZone screens
/// continue to work while the Design System is being migrated.
///

abstract final class AppColors {
  AppColors._();

  // ===============================================================
  // Brand
  // ===============================================================

  static const primary = SemanticColors.primary;
  static const secondary = SemanticColors.secondary;
  static const accent = SemanticColors.accent;

  // Legacy compatibility
  static const primarySoft = SemanticColors.primary;

  static const textLight = Colors.white;

  static const danger = SemanticColors.error;

  // ===============================================================
  // Background
  // ===============================================================

  static const background = SemanticColors.background;

  static const backgroundSecondary =
      SemanticColors.backgroundSecondary;

  static const backgroundTertiary =
      SemanticColors.backgroundTertiary;

  // ===============================================================
  // Surfaces
  // ===============================================================

  static const surface = SemanticColors.surface;

  static const surfaceSecondary =
      SemanticColors.surfaceSecondary;

  static const surfaceElevated =
      SemanticColors.surfaceElevated;

  /// Backward-compatible alias.
  ///
  /// Older screens used `surfaceSoft`.
  /// It maps to the existing secondary surface instead of creating
  /// another color token.
  static const surfaceSoft =
      SemanticColors.surfaceSecondary;

  // ===============================================================
  // Legacy Card Aliases
  // ===============================================================

  /// Legacy API used by older screens.
  static const card = SemanticColors.surface;

  /// Legacy API used by older screens.
  static const cardSoft =
      SemanticColors.surfaceSecondary;

  /// Legacy API used by older screens.
  static const cardElevated =
      SemanticColors.surfaceElevated;

  // ===============================================================
  // Glass
  // ===============================================================

  static const glass = SemanticColors.glass;

  static const glassLight =
      SemanticColors.glassLight;

  static const glassBorder =
      SemanticColors.glassBorder;

  static const glassReflection =
      SemanticColors.glassReflection;

  static const glassHighlight =
      SemanticColors.glassHighlight;

  static const glassShadow =
      SemanticColors.glassShadow;

  /// Base glass opacity used by legacy glass widgets.
  ///
  /// This value intentionally matches the normal glass level.
  static const double glassOpacity = 0.08;

  // ===============================================================
  // Text
  // ===============================================================

  static const text =
      SemanticColors.textPrimary;

  static const textPrimary =
      SemanticColors.textPrimary;

  static const textSecondary =
      SemanticColors.textSecondary;

  static const textMuted =
      SemanticColors.textMuted;

  static const textSoft =
      SemanticColors.textMuted;

  static const textDisabled =
      SemanticColors.textDisabled;

  // ===============================================================
  // Borders
  // ===============================================================

  static const border =
      SemanticColors.border;

  static const borderStrong =
      SemanticColors.borderStrong;

  // ===============================================================
  // Status
  // ===============================================================

  static const success =
      SemanticColors.success;

  static const warning =
      SemanticColors.warning;

  static const error =
      SemanticColors.error;

  // ===============================================================
  // AR / Spatial
  // ===============================================================

  static const portal =
      SemanticColors.portal;

  static const anchor =
      SemanticColors.anchor;

  static const scanner =
      SemanticColors.scanner;

  static const reality =
      SemanticColors.reality;

  static const hologram =
      SemanticColors.hologram;

  static const spatial =
      SemanticColors.spatial;

  // ===============================================================
  // Gradients
  // ===============================================================

  static const primaryGradient =
      SemanticColors.primaryGradient;

  static const glassGradient =
      SemanticColors.glassGradient;

  static const portalGradient =
      SemanticColors.portalGradient;

  // ===============================================================
  // Legacy Gradient Aliases
  // ===============================================================

  /// Legacy API used by older MetaZone UI.
  static const neonGradient =
      SemanticColors.primaryGradient;

  // ===============================================================
  // Theme Compatibility
  // ===============================================================

  /// Legacy compatibility entry point.
  ///
  /// The current MetaZone architecture keeps colors immutable and
  /// delegates actual theme selection to ThemeData / MetaZoneTheme.
  ///
  /// This method remains temporarily so legacy screens can compile
  /// while they migrate away from the old mutable color architecture.
  @Deprecated(
    'Use MetaZoneTheme / ThemeMode instead of AppColors.setTheme().',
  )
  static void setTheme(String key) {
    // Intentionally empty.
    //
    // AppColors is now an immutable design-token layer.
    // Theme switching belongs to ThemeData / ThemeMode.
  }
}