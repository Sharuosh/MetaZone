import 'package:flutter/material.dart';
import 'metazone_theme.dart';

final class MetaZoneThemeData {
  const MetaZoneThemeData._();

  static ThemeData build(
      MetaZoneTheme theme,
      ) {
    return ThemeData(
      useMaterial3: true,
      brightness: theme.brightness,
      colorScheme: theme.colorScheme,
    );
  }
}