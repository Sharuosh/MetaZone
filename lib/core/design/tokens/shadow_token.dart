import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class ShadowToken extends Token<List<BoxShadow>> {
  const ShadowToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.shadow,
  );

  @override
  ShadowToken copyWith({
    String? name,
    List<BoxShadow>? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return ShadowToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  BoxShadow get primary => value.first;

  List<BoxShadow> merge(
      ShadowToken other,
      ) {
    return [
      ...value,
      ...other.value,
    ];
  }
}

abstract final class ShadowElevationScale {
  ShadowElevationScale._();

  static const level0 = 0.0;
  static const level1 = 2.0;
  static const level2 = 4.0;
  static const level3 = 8.0;
  static const level4 = 12.0;
  static const level5 = 16.0;
  static const level6 = 24.0;
  static const level7 = 32.0;
}

abstract final class ShadowTokens {
  ShadowTokens._();

  static final transparent = ShadowToken(
    name: 'shadow.transparent',
    value: const [],
  );

  static final xs = ShadowToken(
    name: 'shadow.xs',
    value: const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
  );

  static final sm = ShadowToken(
    name: 'shadow.sm',
    value: const [
      BoxShadow(
        color: Color(0x18000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static final md = ShadowToken(
    name: 'shadow.md',
    value: const [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 14,
        offset: Offset(0, 5),
      ),
    ],
  );

  static final lg = ShadowToken(
    name: 'shadow.lg',
    value: const [
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 22,
        offset: Offset(0, 8),
      ),
    ],
  );

  static final xl = ShadowToken(
    name: 'shadow.xl',
    value: const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 36,
        offset: Offset(0, 16),
      ),
    ],
  );

  static final glow = ShadowToken(
    name: 'shadow.glow',
    value: const [
      BoxShadow(
        color: Color(0x662D8CFF),
        blurRadius: 30,
        spreadRadius: 2,
      ),
    ],
  );

  static final glass = ShadowToken(
    name: 'shadow.glass',
    value: const [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(
        color: Color(0x08FFFFFF),
        blurRadius: 2,
        spreadRadius: -1,
      ),
    ],
  );

  static final List<ShadowToken> values = [
    transparent,
    xs,
    sm,
    md,
    lg,
    xl,
    glow,
    glass,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension ShadowTokenExtension on ShadowToken {
  BoxDecoration decorate({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: border,
      boxShadow: value,
    );
  }

  PhysicalModel buildPhysicalModel({
    required Widget child,
    required Color color,
    BorderRadius? borderRadius,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return PhysicalModel(
      color: color,
      elevation: primary.blurRadius,
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}