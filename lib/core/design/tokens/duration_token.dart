import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class DurationToken extends Token<Duration> {
  const DurationToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.duration,
  );

  @override
  DurationToken copyWith({
    String? name,
    Duration? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return DurationToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  int get milliseconds => value.inMilliseconds;

  int get microseconds => value.inMicroseconds;

  int get seconds => value.inSeconds;
}

abstract final class DurationScale {
  DurationScale._();

  static const instant = Duration.zero;

  static const ultraFast = Duration(milliseconds: 50);

  static const extraFast = Duration(milliseconds: 100);

  static const veryFast = Duration(milliseconds: 150);

  static const fast = Duration(milliseconds: 200);

  static const normal = Duration(milliseconds: 250);

  static const medium = Duration(milliseconds: 300);

  static const slow = Duration(milliseconds: 400);

  static const slower = Duration(milliseconds: 500);

  static const verySlow = Duration(milliseconds: 700);

  static const extraSlow = Duration(milliseconds: 1000);

  static const cinematic = Duration(milliseconds: 1500);

  static const immersive = Duration(milliseconds: 2000);
}

abstract final class DurationTokens {
  DurationTokens._();

  static final instant = DurationToken(
    name: 'duration.instant',
    value: DurationScale.instant,
  );

  static final ultraFast = DurationToken(
    name: 'duration.ultraFast',
    value: DurationScale.ultraFast,
  );

  static final extraFast = DurationToken(
    name: 'duration.extraFast',
    value: DurationScale.extraFast,
  );

  static final veryFast = DurationToken(
    name: 'duration.veryFast',
    value: DurationScale.veryFast,
  );

  static final fast = DurationToken(
    name: 'duration.fast',
    value: DurationScale.fast,
  );

  static final normal = DurationToken(
    name: 'duration.normal',
    value: DurationScale.normal,
  );

  static final medium = DurationToken(
    name: 'duration.medium',
    value: DurationScale.medium,
  );

  static final slow = DurationToken(
    name: 'duration.slow',
    value: DurationScale.slow,
  );

  static final slower = DurationToken(
    name: 'duration.slower',
    value: DurationScale.slower,
  );

  static final verySlow = DurationToken(
    name: 'duration.verySlow',
    value: DurationScale.verySlow,
  );

  static final extraSlow = DurationToken(
    name: 'duration.extraSlow',
    value: DurationScale.extraSlow,
  );

  static final cinematic = DurationToken(
    name: 'duration.cinematic',
    value: DurationScale.cinematic,
  );

  static final immersive = DurationToken(
    name: 'duration.immersive',
    value: DurationScale.immersive,
  );

  static final List<DurationToken> values = [
    instant,
    ultraFast,
    extraFast,
    veryFast,
    fast,
    normal,
    medium,
    slow,
    slower,
    verySlow,
    extraSlow,
    cinematic,
    immersive,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension DurationTokenExtension on DurationToken {
  Duration operator *(double factor) {
    return Duration(
      milliseconds: (milliseconds * factor).round(),
    );
  }

  Duration operator +(Duration other) {
    return value + other;
  }

  Duration operator -(Duration other) {
    return value - other;
  }

  bool get isInstant => value == Duration.zero;

  bool get isFast => milliseconds <= 200;

  bool get isMedium =>
      milliseconds > 200 &&
          milliseconds <= 500;

  bool get isSlow => milliseconds > 500;
}