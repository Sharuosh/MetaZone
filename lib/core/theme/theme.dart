import 'package:flutter/material.dart';

/// ------------------------------------------------------
///     META ZONE — META THEME ENGINE v3.2
/// ------------------------------------------------------
/// ✔ FULL Backward Compatibility
/// ✔ Zero changes required in existing screens
/// ✔ Safe for large MetaZone codebase
/// ------------------------------------------------------

/// ======================================================
///                    THEME MODEL
/// ======================================================
class MetaThemeModel {
  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color overlay;

  final Color card;
  final Color cardSoft;

  final Color primary;
  final Color primarySoft;
  final Color accent;

  final Color success;
  final Color warning;
  final Color danger;
  final Color focus;

  final Color text;
  final Color textLight;
  final Color textSoft;
  final Color textDisabled;

  final Color border;
  final Color glow;

  final Gradient neonGradient;
  final Gradient surfaceGradient;
  final Gradient glowGradient;

  final double neonIntensity;
  final double glassOpacity;
  final double depthLevel;
  final double blurLevel;
  final double animationSpeed;
  final double textureSharpness;

  const MetaThemeModel({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.overlay,
    required this.card,
    required this.cardSoft,
    required this.primary,
    required this.primarySoft,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.focus,
    required this.text,
    required this.textLight,
    required this.textSoft,
    required this.textDisabled,
    required this.border,
    required this.glow,
    required this.neonGradient,
    required this.surfaceGradient,
    required this.glowGradient,
    required this.neonIntensity,
    required this.glassOpacity,
    required this.depthLevel,
    required this.blurLevel,
    required this.animationSpeed,
    required this.textureSharpness,
  });
}

/// ======================================================
///                     PRESETS
/// ======================================================
class ThemePresets {
  static const MetaThemeModel darkNeon = MetaThemeModel(
    background: Color(0xFF07070C),
    surface: Color(0xFF0E0E15),
    surfaceSoft: Color(0xFF171826),
    overlay: Color(0x99000000),

    card: Color(0xFF12131C),
    cardSoft: Color(0xFF1B1C2A),

    primary: Color(0xFF00D1FF),
    primarySoft: Color(0xFF009EC2),
    accent: Color(0xFF14FFEC),

    success: Color(0xFF3DFF9A),
    warning: Color(0xFFFFC857),
    danger: Color(0xFFFF4D4D),
    focus: Color(0xFF7AE8FF),

    text: Colors.white,
    textLight: Color(0xFFB4B7C9),
    textSoft: Color(0xFF7C7F91),
    textDisabled: Color(0xFF4A4C5A),

    border: Color(0xFF242635),
    glow: Color(0xFF00E5FF),

    neonGradient: LinearGradient(
      colors: [Color(0xFF00D1FF), Color(0xFF14FFEC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    surfaceGradient: LinearGradient(
      colors: [Color(0xFF0F1020), Color(0xFF07070C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    glowGradient: RadialGradient(
      colors: [Color(0x5500E5FF), Colors.transparent],
    ),

    neonIntensity: 1.1,
    glassOpacity: 0.28,
    depthLevel: 0.75,
    blurLevel: 14,
    animationSpeed: 1.0,
    textureSharpness: 0.8,
  );

  static const hologram = darkNeon;
  static const light = darkNeon;
}

/// ======================================================
///               GLOBAL THEME CONTROLLER
/// ======================================================
class AppColors {
  static MetaThemeModel current = ThemePresets.darkNeon;

  static void setTheme(String key) {
    switch (key) {
      case 'hologram':
        current = ThemePresets.hologram;
        break;
      case 'light':
        current = ThemePresets.light;
        break;
      default:
        current = ThemePresets.darkNeon;
    }
  }

  // Core
  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceSoft => current.surfaceSoft;
  static Color get overlay => current.overlay;

  // Cards
  static Color get card => current.card;
  static Color get cardSoft => current.cardSoft;

  // Brand
  static Color get primary => current.primary;
  static Color get primarySoft => current.primarySoft;
  static Color get accent => current.accent;

  // Semantic
  static Color get success => current.success;
  static Color get warning => current.warning;
  static Color get danger => current.danger;
  static Color get focus => current.focus;

  // Text
  static Color get text => current.text;
  static Color get textLight => current.textLight;
  static Color get textSoft => current.textSoft;
  static Color get textDisabled => current.textDisabled;

  // Effects
  static Color get border => current.border;
  static Color get glow => current.glow;

  static Gradient get neonGradient => current.neonGradient;
  static Gradient get surfaceGradient => current.surfaceGradient;
  static Gradient get glowGradient => current.glowGradient;

  // Spatial
  static double get neonIntensity => current.neonIntensity;
  static double get glassOpacity => current.glassOpacity;
  static double get depthLevel => current.depthLevel;
  static double get blurLevel => current.blurLevel;
  static double get animationSpeed => current.animationSpeed;
  static double get textureSharpness => current.textureSharpness;
}

/// ======================================================
///                    TEXT STYLES
/// ======================================================
class AppTextStyles {
  /// 🔒 Backward safe
  static TextStyle heading({double size = 20, Color? color}) =>
      headline(size: size, color: color);

  static TextStyle headline({double size = 24, Color? color}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.text,
      );

  static TextStyle title({double size = 18, Color? color}) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.text,
      );

  static TextStyle body({double size = 14, Color? color}) =>
      TextStyle(
        fontSize: size,
        color: color ?? AppColors.textLight,
      );

  static TextStyle caption({double size = 12, Color? color}) =>
      TextStyle(
        fontSize: size,
        color: color ?? AppColors.textSoft,
      );
}
