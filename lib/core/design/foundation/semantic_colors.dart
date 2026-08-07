import 'package:flutter/material.dart';

import 'color_palette.dart';

/// ===============================================================
/// MetaZone Spatial Glass Design System
/// Semantic Colors
/// ===============================================================
///
/// لا تستخدم MetaPalette داخل الـ UI مباشرة.
/// استخدم SemanticColors فقط.
///
/// مثال:
///
/// SemanticColors.primary
/// SemanticColors.surface
/// SemanticColors.glass
///
abstract final class SemanticColors {
  SemanticColors._();

  // ===========================================================
  // BRAND
  // ===========================================================

  static const primary = MetaPalette.primary500;
  static const primaryHover = MetaPalette.primary400;
  static const primaryPressed = MetaPalette.primary700;

  static const secondary = MetaPalette.cyan500;

  static const accent = MetaPalette.portal;

  // ===========================================================
  // BACKGROUND
  // ===========================================================

  static const background = MetaPalette.void950;
  static const backgroundSecondary = MetaPalette.void900;
  static const backgroundTertiary = MetaPalette.obsidian900;

  // ===========================================================
  // SURFACES
  // ===========================================================

  static const surface = MetaPalette.obsidian800;
  static const surfaceSecondary = MetaPalette.obsidian700;
  static const surfaceElevated = MetaPalette.obsidian600;

  // ===========================================================
  // GLASS
  // ===========================================================

  static const glass = MetaPalette.glassWhite;
  static const glassLight = MetaPalette.glassLight;

  static const glassBorder = MetaPalette.glassBorder;
  static const glassReflection = MetaPalette.glassReflection;
  static const glassHighlight = MetaPalette.glassHighlight;
  static const glassShadow = MetaPalette.glassShadow;

  // ===========================================================
  // TEXT
  // ===========================================================

  static const textPrimary = MetaPalette.neutral0;
  static const textSecondary = MetaPalette.neutral100;
  static const textMuted = MetaPalette.neutral300;
  static const textDisabled = MetaPalette.neutral500;

  // ===========================================================
  // ICONS
  // ===========================================================

  static const iconPrimary = textPrimary;
  static const iconSecondary = textSecondary;
  static const iconMuted = textMuted;

  // ===========================================================
  // BORDER
  // ===========================================================

  static const border = MetaPalette.glassBorder;
  static const borderStrong = MetaPalette.glassReflection;

  // ===========================================================
  // STATUS
  // ===========================================================

  static const success = MetaPalette.emerald500;
  static const warning = MetaPalette.amber500;
  static const error = MetaPalette.red500;

  // ===========================================================
  // AR
  // ===========================================================

  static const portal = MetaPalette.portal;
  static const anchor = MetaPalette.anchor;
  static const scanner = MetaPalette.scanner;
  static const reality = MetaPalette.reality;
  static const hologram = MetaPalette.hologram;
  static const spatial = MetaPalette.spatial;

  // ===========================================================
  // GRADIENTS
  // ===========================================================

  static const primaryGradient = MetaPalette.primaryGradient;
  static const glassGradient = MetaPalette.glassGradient;
  static const portalGradient = MetaPalette.portalGradient;
}