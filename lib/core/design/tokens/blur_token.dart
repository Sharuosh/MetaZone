import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class BlurToken extends Token<double> {
  const BlurToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.blur,
  );

  @override
  BlurToken copyWith({
    String? name,
    double? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return BlurToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  ImageFilter get filter => ImageFilter.blur(
    sigmaX: value,
    sigmaY: value,
  );

  ImageFilter filterXY({
    double? sigmaX,
    double? sigmaY,
  }) {
    return ImageFilter.blur(
      sigmaX: sigmaX ?? value,
      sigmaY: sigmaY ?? value,
    );
  }
}

abstract final class BlurScale {
  BlurScale._();

  static const none = 0.0;

  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const xxxl = 24.0;
  static const ultra = 32.0;
  static const immersive = 40.0;
}

abstract final class BlurTokens {
  BlurTokens._();

  static final none = BlurToken(
    name: 'blur.none',
    value: BlurScale.none,
  );

  static final xxs = BlurToken(
    name: 'blur.xxs',
    value: BlurScale.xxs,
  );

  static final xs = BlurToken(
    name: 'blur.xs',
    value: BlurScale.xs,
  );

  static final sm = BlurToken(
    name: 'blur.sm',
    value: BlurScale.sm,
  );

  static final md = BlurToken(
    name: 'blur.md',
    value: BlurScale.md,
  );

  static final lg = BlurToken(
    name: 'blur.lg',
    value: BlurScale.lg,
  );

  static final xl = BlurToken(
    name: 'blur.xl',
    value: BlurScale.xl,
  );

  static final xxl = BlurToken(
    name: 'blur.xxl',
    value: BlurScale.xxl,
  );

  static final xxxl = BlurToken(
    name: 'blur.xxxl',
    value: BlurScale.xxxl,
  );

  static final ultra = BlurToken(
    name: 'blur.ultra',
    value: BlurScale.ultra,
  );

  static final immersive = BlurToken(
    name: 'blur.immersive',
    value: BlurScale.immersive,
  );

  static final List<BlurToken> values = [
    none,
    xxs,
    xs,
    sm,
    md,
    lg,
    xl,
    xxl,
    xxxl,
    ultra,
    immersive,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension BlurTokenExtension on BlurToken {
  ImageFilter operator +(BlurToken other) {
    return ImageFilter.blur(
      sigmaX: value + other.value,
      sigmaY: value + other.value,
    );
  }

  ImageFilter scale(double factor) {
    return ImageFilter.blur(
      sigmaX: value * factor,
      sigmaY: value * factor,
    );
  }

  bool get isZero => value == 0;

  bool get isGlass => value >= BlurScale.lg;

  bool get isHeavy => value >= BlurScale.ultra;
}