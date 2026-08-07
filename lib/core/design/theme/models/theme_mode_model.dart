import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// MetaZone Theme Mode
/// ---------------------------------------------------------------------------
///
/// Internal theme representation used across the entire application.
/// This model is intentionally independent from storage, services,
/// repositories, and UI logic.
///
/// Responsibilities:
/// • Represent the application's theme mode.
/// • Convert to/from Flutter ThemeMode.
/// • Convert to/from storage values.
/// • Provide serialization utilities.
///
/// NOTE:
/// This file MUST remain free of any business logic.
/// ---------------------------------------------------------------------------

enum MetaZoneThemeMode {
  system,
  light,
  dark,
}

extension MetaZoneThemeModeExtension on MetaZoneThemeMode {
  /// Storage value.
  String get value => name;

  /// Flutter ThemeMode conversion.
  ThemeMode get flutterThemeMode {
    switch (this) {
      case MetaZoneThemeMode.system:
        return ThemeMode.system;

      case MetaZoneThemeMode.light:
        return ThemeMode.light;

      case MetaZoneThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Human readable label.
  String get label {
    switch (this) {
      case MetaZoneThemeMode.system:
        return 'System';

      case MetaZoneThemeMode.light:
        return 'Light';

      case MetaZoneThemeMode.dark:
        return 'Dark';
    }
  }

  /// Whether this mode follows the operating system.
  bool get followsSystem => this == MetaZoneThemeMode.system;

  bool get isLight => this == MetaZoneThemeMode.light;

  bool get isDark => this == MetaZoneThemeMode.dark;
}

extension ThemeModeExtension on ThemeMode {
  MetaZoneThemeMode get metaZoneMode {
    switch (this) {
      case ThemeMode.system:
        return MetaZoneThemeMode.system;

      case ThemeMode.light:
        return MetaZoneThemeMode.light;

      case ThemeMode.dark:
        return MetaZoneThemeMode.dark;
    }
  }
}

final class MetaZoneThemeModeParser {
  const MetaZoneThemeModeParser._();

  static MetaZoneThemeMode fromStorage(String? value) {
    switch (value) {
      case 'light':
        return MetaZoneThemeMode.light;

      case 'dark':
        return MetaZoneThemeMode.dark;

      default:
        return MetaZoneThemeMode.system;
    }
  }

  static String toStorage(MetaZoneThemeMode mode) {
    return mode.value;
  }
}