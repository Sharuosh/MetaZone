import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class CurveToken extends Token<Curve> {
  const CurveToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.curve,
  );

  @override
  CurveToken copyWith({
    String? name,
    Curve? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return CurveToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  Curve get curve => value;
}

abstract final class CurveTokens {
  CurveTokens._();

  static final linear = CurveToken(
    name: 'curve.linear',
    value: Curves.linear,
  );

  static final ease = CurveToken(
    name: 'curve.ease',
    value: Curves.ease,
  );

  static final easeIn = CurveToken(
    name: 'curve.easeIn',
    value: Curves.easeIn,
  );

  static final easeOut = CurveToken(
    name: 'curve.easeOut',
    value: Curves.easeOut,
  );

  static final easeInOut = CurveToken(
    name: 'curve.easeInOut',
    value: Curves.easeInOut,
  );

  static final fastOutSlowIn = CurveToken(
    name: 'curve.fastOutSlowIn',
    value: Curves.fastOutSlowIn,
  );

  static final slowMiddle = CurveToken(
    name: 'curve.slowMiddle',
    value: Curves.slowMiddle,
  );

  static final decelerate = CurveToken(
    name: 'curve.decelerate',
    value: Curves.decelerate,
  );

  static final elasticOut = CurveToken(
    name: 'curve.elasticOut',
    value: Curves.elasticOut,
  );

  static final elasticInOut = CurveToken(
    name: 'curve.elasticInOut',
    value: Curves.elasticInOut,
  );

  static final bounceOut = CurveToken(
    name: 'curve.bounceOut',
    value: Curves.bounceOut,
  );

  static final bounceInOut = CurveToken(
    name: 'curve.bounceInOut',
    value: Curves.bounceInOut,
  );

  static final List<CurveToken> values = [
    linear,
    ease,
    easeIn,
    easeOut,
    easeInOut,
    fastOutSlowIn,
    slowMiddle,
    decelerate,
    elasticOut,
    elasticInOut,
    bounceOut,
    bounceInOut,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension CurveTokenExtension on CurveToken {
  bool get isLinear => value == Curves.linear;

  bool get isEase => value == Curves.ease;

  bool get isElastic =>
      value == Curves.elasticOut ||
          value == Curves.elasticInOut;

  bool get isBounce =>
      value == Curves.bounceOut ||
          value == Curves.bounceInOut;
}