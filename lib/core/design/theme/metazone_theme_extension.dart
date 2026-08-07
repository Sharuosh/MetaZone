import 'package:flutter/material.dart';

@immutable
class MetaZoneThemeExtension
    extends ThemeExtension<MetaZoneThemeExtension> {
  const MetaZoneThemeExtension();

  @override
  MetaZoneThemeExtension copyWith() {
    return const MetaZoneThemeExtension();
  }

  @override
  ThemeExtension<MetaZoneThemeExtension> lerp(
      covariant ThemeExtension<MetaZoneThemeExtension>? other,
      double t,
      ) {
    return const MetaZoneThemeExtension();
  }
}