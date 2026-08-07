import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class GradientToken extends Token<Gradient> {
  const GradientToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.gradient,
  );

  @override
  GradientToken copyWith({
    String? name,
    Gradient? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return GradientToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  Gradient get gradient => value;

  BoxDecoration decorate({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: value,
      borderRadius: borderRadius,
    );
  }
}

abstract final class GradientTokens {
  GradientTokens._();

  static final aurora = GradientToken(
    name: 'gradient.aurora',
    value: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF5B5FFF),
        Color(0xFF8E5CFF),
      ],
    ),
  );

  static final cosmic = GradientToken(
    name: 'gradient.cosmic',
    value: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0F172A),
        Color(0xFF1E293B),
      ],
    ),
  );

  static final glass = GradientToken(
    name: 'gradient.glass',
    value: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x33FFFFFF),
        Color(0x10FFFFFF),
      ],
    ),
  );

  static final sunset = GradientToken(
    name: 'gradient.sunset',
    value: const LinearGradient(
      colors: [
        Color(0xFFFF9966),
        Color(0xFFFF5E62),
      ],
    ),
  );

  static final ocean = GradientToken(
    name: 'gradient.ocean',
    value: const LinearGradient(
      colors: [
        Color(0xFF00C6FF),
        Color(0xFF0072FF),
      ],
    ),
  );

  static final emerald = GradientToken(
    name: 'gradient.emerald',
    value: const LinearGradient(
      colors: [
        Color(0xFF00C896),
        Color(0xFF009966),
      ],
    ),
  );

  static final List<GradientToken> values = [
    aurora,
    cosmic,
    glass,
    sunset,
    ocean,
    emerald,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension GradientTokenExtension on GradientToken {
  Shader createShader(Rect rect) {
    return value.createShader(rect);
  }

  Paint toPaint(Rect rect) {
    return Paint()
      ..shader = createShader(rect);
  }

  bool get isLinear => value is LinearGradient;

  bool get isRadial => value is RadialGradient;

  bool get isSweep => value is SweepGradient;
}