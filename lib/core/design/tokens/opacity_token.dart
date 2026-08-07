import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class OpacityToken extends Token<double> {
  const OpacityToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.opacity,
  );

  @override
  OpacityToken copyWith({
    String? name,
    double? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return OpacityToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  double clamp() => value.clamp(0.0, 1.0);

  double percent() => clamp() * 100.0;
}

abstract final class OpacityScale {
  OpacityScale._();

  static const transparent = 0.00;

  static const ultraLow = 0.04;
  static const veryLow = 0.08;
  static const low = 0.12;

  static const subtle = 0.16;
  static const soft = 0.24;

  static const medium = 0.38;

  static const visible = 0.54;

  static const strong = 0.72;

  static const high = 0.84;

  static const almostOpaque = 0.92;

  static const opaque = 1.00;
}

abstract final class OpacityTokens {
  OpacityTokens._();

  static final transparent = OpacityToken(
    name: 'opacity.transparent',
    value: OpacityScale.transparent,
  );

  static final ultraLow = OpacityToken(
    name: 'opacity.ultraLow',
    value: OpacityScale.ultraLow,
  );

  static final veryLow = OpacityToken(
    name: 'opacity.veryLow',
    value: OpacityScale.veryLow,
  );

  static final low = OpacityToken(
    name: 'opacity.low',
    value: OpacityScale.low,
  );

  static final subtle = OpacityToken(
    name: 'opacity.subtle',
    value: OpacityScale.subtle,
  );

  static final soft = OpacityToken(
    name: 'opacity.soft',
    value: OpacityScale.soft,
  );

  static final medium = OpacityToken(
    name: 'opacity.medium',
    value: OpacityScale.medium,
  );

  static final visible = OpacityToken(
    name: 'opacity.visible',
    value: OpacityScale.visible,
  );

  static final strong = OpacityToken(
    name: 'opacity.strong',
    value: OpacityScale.strong,
  );

  static final high = OpacityToken(
    name: 'opacity.high',
    value: OpacityScale.high,
  );

  static final almostOpaque = OpacityToken(
    name: 'opacity.almostOpaque',
    value: OpacityScale.almostOpaque,
  );

  static final opaque = OpacityToken(
    name: 'opacity.opaque',
    value: OpacityScale.opaque,
  );

  static final List<OpacityToken> values = [
    transparent,
    ultraLow,
    veryLow,
    low,
    subtle,
    soft,
    medium,
    visible,
    strong,
    high,
    almostOpaque,
    opaque,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension OpacityTokenExtension on OpacityToken {
  double operator *(double factor) {
    return (value * factor).clamp(0.0, 1.0);
  }

  double operator +(double amount) {
    return (value + amount).clamp(0.0, 1.0);
  }

  double operator -(double amount) {
    return (value - amount).clamp(0.0, 1.0);
  }

  bool get isTransparent => value == 0;

  bool get isOpaque => value >= 1.0;

  bool get isVisible => value >= 0.5;

  bool get isGlass =>
      value >= 0.10 && value <= 0.35;
}