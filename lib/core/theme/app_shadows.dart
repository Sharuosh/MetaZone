import 'package:flutter/material.dart';

/// ===============================================================
/// MetaZone Shadow System
/// Spatial Glass Design
/// ===============================================================

abstract final class AppShadows {
  AppShadows._();

  static List<BoxShadow> get xs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .10),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .14),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .18),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .22),
      blurRadius: 36,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .25),
      blurRadius: 40,
      offset: const Offset(0, 18),
    ),
  ];

  static List<BoxShadow> get glass => [
    BoxShadow(
      color: Colors.black.withValues(alpha: .16),
      blurRadius: 28,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: .04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get glowPrimary => [
    BoxShadow(
      color: const Color(0xFF8B5CF6).withValues(alpha: .45),
      blurRadius: 40,
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get glowCyan => [
    BoxShadow(
      color: const Color(0xFF06B6D4).withValues(alpha: .45),
      blurRadius: 40,
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get portal => [
    ...glass,
    ...glowPrimary,
  ];

  static List<BoxShadow> get hologram => [
    ...glass,
    ...glowCyan,
  ];
}