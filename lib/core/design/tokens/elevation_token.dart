import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class ElevationToken extends Token<double> {
  const ElevationToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.elevation,
  );

  @override
  ElevationToken copyWith({
    String? name,
    double? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return ElevationToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  double get elevation => value;
}

abstract final class ElevationScale {
  ElevationScale._();

  static const flat = 0.0;

  static const level1 = 1.0;
  static const level2 = 2.0;
  static const level3 = 3.0;
  static const level4 = 4.0;
  static const level6 = 6.0;
  static const level8 = 8.0;
  static const level12 = 12.0;
  static const level16 = 16.0;
  static const level20 = 20.0;
  static const level24 = 24.0;
  static const level32 = 32.0;
  static const floating = 40.0;
}

abstract final class ElevationTokens {
  ElevationTokens._();

  static final flat = ElevationToken(
    name: 'elevation.flat',
    value: ElevationScale.flat,
  );

  static final level1 = ElevationToken(
    name: 'elevation.level1',
    value: ElevationScale.level1,
  );

  static final level2 = ElevationToken(
    name: 'elevation.level2',
    value: ElevationScale.level2,
  );

  static final level3 = ElevationToken(
    name: 'elevation.level3',
    value: ElevationScale.level3,
  );

  static final level4 = ElevationToken(
    name: 'elevation.level4',
    value: ElevationScale.level4,
  );

  static final level6 = ElevationToken(
    name: 'elevation.level6',
    value: ElevationScale.level6,
  );

  static final level8 = ElevationToken(
    name: 'elevation.level8',
    value: ElevationScale.level8,
  );

  static final level12 = ElevationToken(
    name: 'elevation.level12',
    value: ElevationScale.level12,
  );

  static final level16 = ElevationToken(
    name: 'elevation.level16',
    value: ElevationScale.level16,
  );

  static final level20 = ElevationToken(
    name: 'elevation.level20',
    value: ElevationScale.level20,
  );

  static final level24 = ElevationToken(
    name: 'elevation.level24',
    value: ElevationScale.level24,
  );

  static final level32 = ElevationToken(
    name: 'elevation.level32',
    value: ElevationScale.level32,
  );

  static final floating = ElevationToken(
    name: 'elevation.floating',
    value: ElevationScale.floating,
  );

  static final List<ElevationToken> values = [
    flat,
    level1,
    level2,
    level3,
    level4,
    level6,
    level8,
    level12,
    level16,
    level20,
    level24,
    level32,
    floating,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension ElevationTokenExtension on ElevationToken {
  double operator +(double value) => elevation + value;

  double operator -(double value) => elevation - value;

  double operator *(double factor) => elevation * factor;

  bool get isFlat => elevation == 0;

  bool get isRaised =>
      elevation > 0 && elevation <= 8;

  bool get isFloating =>
      elevation > 8 && elevation <= 24;

  bool get isOverlay =>
      elevation > 24;
}