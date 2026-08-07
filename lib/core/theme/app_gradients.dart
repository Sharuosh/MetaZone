import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ===============================================================
/// MetaZone Gradient System
/// Spatial Glass Design
/// ===============================================================

abstract final class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.secondary,
    ],
  );

  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.glassReflection,
      AppColors.glassLight,
    ],
  );

  static const LinearGradient portal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.portal,
      AppColors.secondary,
    ],
  );

  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
    ],
  );

  static const LinearGradient cosmic = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF05070A),
      Color(0xFF111827),
      Color(0xFF1E293B),
    ],
  );

  static const LinearGradient crystal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x15FFFFFF),
    ],
  );

  static const LinearGradient scanner = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.scanner,
      AppColors.secondary,
    ],
  );

  static const LinearGradient hologram = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.hologram,
      AppColors.secondary,
    ],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.success,
      Color(0xFF34D399),
    ],
  );

  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.warning,
      Color(0xFFFBBF24),
    ],
  );

  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.error,
      Color(0xFFF87171),
    ],
  );
}