import 'package:flutter/material.dart';

/// ===============================================================
/// MetaZone Spatial Glass Design System
/// Foundation Color Palette
/// ===============================================================

abstract final class MetaPalette {
  MetaPalette._();

  // ===========================================================
  // VOID
  // ===========================================================

  static const void950 = Color(0xFF020305);
  static const void900 = Color(0xFF05070A);
  static const void850 = Color(0xFF090B10);
  static const void800 = Color(0xFF0D1117);

  // ===========================================================
  // OBSIDIAN
  // ===========================================================

  static const obsidian900 = Color(0xFF111827);
  static const obsidian800 = Color(0xFF172033);
  static const obsidian700 = Color(0xFF1E293B);
  static const obsidian600 = Color(0xFF253247);

  // ===========================================================
  // NEUTRAL
  // ===========================================================

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral25 = Color(0xFFF9FAFB);
  static const neutral50 = Color(0xFFF3F4F6);
  static const neutral100 = Color(0xFFE5E7EB);
  static const neutral200 = Color(0xFFD1D5DB);
  static const neutral300 = Color(0xFF9CA3AF);
  static const neutral400 = Color(0xFF6B7280);
  static const neutral500 = Color(0xFF4B5563);
  static const neutral600 = Color(0xFF374151);
  static const neutral700 = Color(0xFF1F2937);
  static const neutral800 = Color(0xFF111827);
  static const neutral900 = Color(0xFF030712);

  // ===========================================================
  // PRIMARY
  // ===========================================================

  static const primary50 = Color(0xFFF5F3FF);
  static const primary100 = Color(0xFFEDE9FE);
  static const primary200 = Color(0xFFDDD6FE);
  static const primary300 = Color(0xFFC4B5FD);
  static const primary400 = Color(0xFFA78BFA);
  static const primary500 = Color(0xFF8B5CF6);
  static const primary600 = Color(0xFF7C3AED);
  static const primary700 = Color(0xFF6D28D9);
  static const primary800 = Color(0xFF5B21B6);
  static const primary900 = Color(0xFF4C1D95);

  // ===========================================================
  // CYAN
  // ===========================================================

  static const cyan50 = Color(0xFFECFEFF);
  static const cyan100 = Color(0xFFCFFAFE);
  static const cyan200 = Color(0xFFA5F3FC);
  static const cyan300 = Color(0xFF67E8F9);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const cyan700 = Color(0xFF0E7490);
  static const cyan800 = Color(0xFF155E75);
  static const cyan900 = Color(0xFF164E63);

  // ===========================================================
  // EMERALD
  // ===========================================================

  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);

  // ===========================================================
  // WARNING
  // ===========================================================

  static const amber500 = Color(0xFFF59E0B);

  // ===========================================================
  // ERROR
  // ===========================================================

  static const red500 = Color(0xFFEF4444);

  // ===========================================================
  // GLASS
  // ===========================================================

  static const glassWhite = Color(0x33FFFFFF);
  static const glassLight = Color(0x22FFFFFF);
  static const glassBorder = Color(0x40FFFFFF);
  static const glassReflection = Color(0x66FFFFFF);
  static const glassHighlight = Color(0x99FFFFFF);

  static const glassDark = Color(0x22000000);
  static const glassShadow = Color(0x55000000);

  // ===========================================================
  // SPATIAL
  // ===========================================================

  static const portal = Color(0xFF8B5CF6);
  static const reality = Color(0xFF06B6D4);
  static const anchor = Color(0xFF10B981);
  static const scanner = Color(0xFFF59E0B);
  static const hologram = Color(0xFF60A5FA);
  static const spatial = Color(0xFFA855F7);

  // ===========================================================
  // GRADIENTS
  // ===========================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primary500,
      cyan500,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      glassReflection,
      glassLight,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient portalGradient = LinearGradient(
    colors: [
      primary600,
      cyan400,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}