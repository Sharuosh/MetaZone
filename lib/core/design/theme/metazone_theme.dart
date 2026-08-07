import 'package:flutter/material.dart';

final class MetaZoneTheme {
  const MetaZoneTheme({
    required this.brightness,
    required this.colorScheme,
  });

  final Brightness brightness;
  final ColorScheme colorScheme;

  factory MetaZoneTheme.light() {
    return MetaZoneTheme(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00D4FF),
        brightness: Brightness.light,
      ),
    );
  }

  factory MetaZoneTheme.dark() {
    return MetaZoneTheme(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00D4FF),
        brightness: Brightness.dark,
      ),
    );
  }
}