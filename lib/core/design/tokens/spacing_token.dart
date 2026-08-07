import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class SpacingToken extends Token<double> {
  const SpacingToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.spacing,
  );

  @override
  SpacingToken copyWith({
    String? name,
    double? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return SpacingToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }
}

abstract final class SpacingScale {
  SpacingScale._();

  static const none = 0.0;

  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const huge = 48.0;
  static const giant = 56.0;
  static const massive = 64.0;
  static const colossal = 72.0;
  static const ultra = 80.0;
  static const infinity = 96.0;
}

abstract final class SpacingTokens {
  SpacingTokens._();

  static final xxs = SpacingToken(
    name: 'spacing.xxs',
    value: SpacingScale.xxs,
  );

  static final xs = SpacingToken(
    name: 'spacing.xs',
    value: SpacingScale.xs,
  );

  static final sm = SpacingToken(
    name: 'spacing.sm',
    value: SpacingScale.sm,
  );

  static final md = SpacingToken(
    name: 'spacing.md',
    value: SpacingScale.md,
  );

  static final lg = SpacingToken(
    name: 'spacing.lg',
    value: SpacingScale.lg,
  );

  static final xl = SpacingToken(
    name: 'spacing.xl',
    value: SpacingScale.xl,
  );

  static final xxl = SpacingToken(
    name: 'spacing.xxl',
    value: SpacingScale.xxl,
  );

  static final xxxl = SpacingToken(
    name: 'spacing.xxxl',
    value: SpacingScale.xxxl,
  );

  static final huge = SpacingToken(
    name: 'spacing.huge',
    value: SpacingScale.huge,
  );

  static final giant = SpacingToken(
    name: 'spacing.giant',
    value: SpacingScale.giant,
  );

  static final massive = SpacingToken(
    name: 'spacing.massive',
    value: SpacingScale.massive,
  );

  static final colossal = SpacingToken(
    name: 'spacing.colossal',
    value: SpacingScale.colossal,
  );

  static final ultra = SpacingToken(
    name: 'spacing.ultra',
    value: SpacingScale.ultra,
  );

  static final infinity = SpacingToken(
    name: 'spacing.infinity',
    value: SpacingScale.infinity,
  );

  static final List<SpacingToken> values = [
    xxs,
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
    colossal,
    ultra,
    infinity,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension SpacingTokenExtension on SpacingToken {
  double operator *(double factor) => value * factor;

  double operator /(double factor) => value / factor;

  double operator +(double other) => value + other;

  double operator -(double other) => value - other;
}