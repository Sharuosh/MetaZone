import 'package:flutter/material.dart';

import '../design/foundation/semantic_colors.dart';

/// ===============================================================
/// MetaZone Theme Colors
/// ===============================================================
///
/// لا تستخدم SemanticColors مباشرة داخل الـ UI.
/// استخدم AppColors فقط.
///

abstract final class AppColors {
  AppColors._();

  // ----------------------------------------------------------------
  // Brand
  // ----------------------------------------------------------------

  static const primary = SemanticColors.primary;
  static const secondary = SemanticColors.secondary;
  static const accent = SemanticColors.accent;

  // ----------------------------------------------------------------
  // Background
  // ----------------------------------------------------------------

  static const background = SemanticColors.background;

  static const backgroundSecondary =
      SemanticColors.backgroundSecondary;

  static const backgroundTertiary =
      SemanticColors.backgroundTertiary;

  // ----------------------------------------------------------------
  // Surfaces
  // ----------------------------------------------------------------

  static const surface = SemanticColors.surface;

  static const surfaceSecondary =
      SemanticColors.surfaceSecondary;

  static const surfaceElevated =
      SemanticColors.surfaceElevated;

  // ===========================
  // Backward Compatibility
  // ===========================

  static const card = surface;

  static const cardSoft = surfaceSecondary;

  static const panel = surfaceElevated;

  static const panelSoft = surfaceSecondary;

  // ----------------------------------------------------------------
  // Glass
  // ----------------------------------------------------------------

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

  // ----------------------------------------------------------------
  // Text
  // ----------------------------------------------------------------

  static const text =
      SemanticColors.textPrimary;

  static const textPrimary = text;

  static const textSecondary =
      SemanticColors.textSecondary;

  static const textMuted =
      SemanticColors.textMuted;

  static const textDisabled =
      SemanticColors.textDisabled;

  // ===========================
  // Backward Compatibility
  // ===========================

  static const textLight = text;

  static const textSoft = textSecondary;

  // ----------------------------------------------------------------
  // Border
  // ----------------------------------------------------------------

  static const border =
      SemanticColors.border;

  static const borderStrong =
      SemanticColors.borderStrong;

  // ----------------------------------------------------------------
  // Status
  // ----------------------------------------------------------------

  static const success =
      SemanticColors.success;

  static const warning =
      SemanticColors.warning;

  static const error =
      SemanticColors.error;

  static const danger = error;

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  static const primarySoft = accent;

  static const accentSoft = accent;

  // ----------------------------------------------------------------
  // AR
  // ----------------------------------------------------------------

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

  // ----------------------------------------------------------------
  // Gradients
  // ----------------------------------------------------------------

  static const primaryGradient =
      SemanticColors.primaryGradient;

  static const glassGradient =
      SemanticColors.glassGradient;

  static const portalGradient =
      SemanticColors.portalGradient;

  // ===========================
  // Compatibility
  // ===========================

  static const neonGradient =
      SemanticColors.primaryGradient;
}