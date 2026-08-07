import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class RadiusToken extends Token<double> {
  const RadiusToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.radius,
  );

  @override
  RadiusToken copyWith({
    String? name,
    double? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return RadiusToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  Radius get radius => Radius.circular(value);

  BorderRadius get borderRadius =>
      BorderRadius.circular(value);

  RRect toRRect(Rect rect) {
    return borderRadius.toRRect(rect);
  }
}

abstract final class RadiusScale {
  RadiusScale._();

  static const none = 0.0;

  static const xs = 2.0;
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const xxxl = 24.0;
  static const huge = 28.0;
  static const giant = 32.0;
  static const massive = 40.0;
  static const capsule = 9999.0;
}

abstract final class RadiusTokens {
  RadiusTokens._();

  static final xs = RadiusToken(
    name: 'radius.xs',
    value: RadiusScale.xs,
  );

  static final sm = RadiusToken(
    name: 'radius.sm',
    value: RadiusScale.sm,
  );

  static final md = RadiusToken(
    name: 'radius.md',
    value: RadiusScale.md,
  );

  static final lg = RadiusToken(
    name: 'radius.lg',
    value: RadiusScale.lg,
  );

  static final xl = RadiusToken(
    name: 'radius.xl',
    value: RadiusScale.xl,
  );

  static final xxl = RadiusToken(
    name: 'radius.xxl',
    value: RadiusScale.xxl,
  );

  static final xxxl = RadiusToken(
    name: 'radius.xxxl',
    value: RadiusScale.xxxl,
  );

  static final huge = RadiusToken(
    name: 'radius.huge',
    value: RadiusScale.huge,
  );

  static final giant = RadiusToken(
    name: 'radius.giant',
    value: RadiusScale.giant,
  );

  static final massive = RadiusToken(
    name: 'radius.massive',
    value: RadiusScale.massive,
  );

  static final capsule = RadiusToken(
    name: 'radius.capsule',
    value: RadiusScale.capsule,
  );

  static final List<RadiusToken> values = [
    xs,
    sm,
    md,
    lg,
    xl,
    xxl,
    xxxl,
    huge,
    giant,
    massive,
    capsule,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension RadiusTokenExtension on RadiusToken {
  RadiusToken scale(double factor) {
    return RadiusToken(
      name: name,
      value: value * factor,
      description: description,
      isDeprecated: isDeprecated,
      alias: alias,
    );
  }

  BorderRadius only({
    bool topLeft = true,
    bool topRight = true,
    bool bottomLeft = true,
    bool bottomRight = true,
  }) {
    return BorderRadius.only(
      topLeft: topLeft ? radius : Radius.zero,
      topRight: topRight ? radius : Radius.zero,
      bottomLeft: bottomLeft ? radius : Radius.zero,
      bottomRight: bottomRight ? radius : Radius.zero,
    );
  }
}