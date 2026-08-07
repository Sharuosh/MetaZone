import 'package:flutter/material.dart';

import '../models/theme_mode_model.dart';

/// ---------------------------------------------------------------------------
/// MetaZone Theme State
/// ---------------------------------------------------------------------------
///
/// Immutable state for the Theme Module.
///
/// Responsibilities:
/// • Hold the current theme mode.
/// • Hold the current platform brightness.
/// • Calculate the effective brightness.
/// • Expose helper getters.
///
/// This class MUST NOT:
/// • Read SharedPreferences.
/// • Notify listeners.
/// • Build ThemeData.
/// • Contain business logic.
/// • Know about repositories or services.
/// ---------------------------------------------------------------------------

@immutable
final class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.platformBrightness,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: MetaZoneThemeMode.system,
      platformBrightness: Brightness.light,
    );
  }

  final MetaZoneThemeMode themeMode;

  final Brightness platformBrightness;

  bool get isSystem => themeMode == MetaZoneThemeMode.system;

  bool get isLight => themeMode == MetaZoneThemeMode.light;

  bool get isDark => themeMode == MetaZoneThemeMode.dark;

  Brightness get effectiveBrightness {
    switch (themeMode) {
      case MetaZoneThemeMode.system:
        return platformBrightness;

      case MetaZoneThemeMode.light:
        return Brightness.light;

      case MetaZoneThemeMode.dark:
        return Brightness.dark;
    }
  }

  bool get useDarkTheme =>
      effectiveBrightness == Brightness.dark;

  ThemeMode get flutterThemeMode =>
      themeMode.flutterThemeMode;

  ThemeState copyWith({
    MetaZoneThemeMode? themeMode,
    Brightness? platformBrightness,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      platformBrightness:
      platformBrightness ?? this.platformBrightness,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ThemeState &&
            other.themeMode == themeMode &&
            other.platformBrightness ==
                platformBrightness;
  }

  @override
  int get hashCode =>
      Object.hash(themeMode, platformBrightness);

  @override
  String toString() {
    return 'ThemeState('
        'themeMode: $themeMode, '
        'platformBrightness: $platformBrightness'
        ')';
  }
}