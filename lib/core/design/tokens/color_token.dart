import 'package:flutter/material.dart';

import 'design_token.dart';
import 'token.dart';

/// Strongly typed color token.
@immutable
class ColorToken extends Token<Color> {
  const ColorToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.color,
  );

  @override
  ColorToken copyWith({
    String? name,
    Color? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return ColorToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  Color withOpacity(double opacity) {
    return value.withOpacity(opacity);
  }

  Color lighten([double amount = .08]) {
    final hsl = HSLColor.fromColor(value);

    return hsl
        .withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color darken([double amount = .08]) {
    final hsl = HSLColor.fromColor(value);

    return hsl
        .withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color saturate([double amount = .05]) {
    final hsl = HSLColor.fromColor(value);

    return hsl
        .withSaturation(
      (hsl.saturation + amount).clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color desaturate([double amount = .05]) {
    final hsl = HSLColor.fromColor(value);

    return hsl
        .withSaturation(
      (hsl.saturation - amount).clamp(0.0, 1.0),
    )
        .toColor();
  }

  Color blend(
      Color other, {
        double amount = .50,
      }) {
    return Color.lerp(
      value,
      other,
      amount,
    ) ??
        value;
  }

  Brightness get brightness {
    return ThemeData.estimateBrightnessForColor(value);
  }

  bool get isDark => brightness == Brightness.dark;

  bool get isLight => brightness == Brightness.light;

  Color get onColor =>
      isDark ? Colors.white : Colors.black;
}