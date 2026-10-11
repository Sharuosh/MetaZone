import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ===============================================================
/// MetaZone Theme Presets
/// ===============================================================
///
/// Preset gradients used by the Appearance settings.
///
/// These presets are intentionally built on top of the existing
/// MetaZone Design System instead of introducing new color tokens.
/// ===============================================================

abstract final class ThemePresets {
  ThemePresets._();

  static const MetaThemePreset darkNeon = MetaThemePreset(
    name: 'Dark Neon',
    neonGradient: AppColors.primaryGradient,
  );

  static const MetaThemePreset hologram = MetaThemePreset(
    name: 'Hologram',
    neonGradient: AppColors.glassGradient,
  );

  static const MetaThemePreset light = MetaThemePreset(
    name: 'Light',
    neonGradient: AppColors.portalGradient,
  );
}

/// ===============================================================
/// Theme Preset Model
/// ===============================================================

final class MetaThemePreset {
  const MetaThemePreset({
    required this.name,
    required this.neonGradient,
  });

  final String name;
  final LinearGradient neonGradient;
}