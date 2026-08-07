import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'design_token.dart';
import 'token.dart';

/// Represents a reusable border token.
@immutable
class BorderToken extends Token<Border> {
  const BorderToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.border,
  );

  @override
  BorderToken copyWith({
    String? name,
    Border? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return BorderToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  BorderSide get top => value.top;

  BorderSide get right => value.right;

  BorderSide get bottom => value.bottom;

  BorderSide get left => value.left;
}

/// Border widths used across MetaZone.
abstract final class BorderScale {
  BorderScale._();

  static const hairline = .25;
  static const thin = .5;
  static const regular = 1.0;
  static const medium = 1.5;
  static const thick = 2.0;
  static const heavy = 3.0;
  static const massive = 4.0;
}

/// Built-in border tokens.
abstract final class BorderTokens {
  BorderTokens._();

  static final transparent = BorderToken(
    name: 'border.transparent',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Colors.transparent,
        width: BorderScale.regular,
      ),
    ),
  );

  static final hairline = BorderToken(
    name: 'border.hairline',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0x14FFFFFF),
        width: BorderScale.hairline,
      ),
    ),
  );

  static final subtle = BorderToken(
    name: 'border.subtle',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0x22FFFFFF),
        width: BorderScale.thin,
      ),
    ),
  );

  static final regular = BorderToken(
    name: 'border.regular',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0x33FFFFFF),
        width: BorderScale.regular,
      ),
    ),
  );

  static final strong = BorderToken(
    name: 'border.strong',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0x66FFFFFF),
        width: BorderScale.medium,
      ),
    ),
  );

  static final accent = BorderToken(
    name: 'border.accent',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0xFF5B5FFF),
        width: BorderScale.thick,
      ),
    ),
  );

  static final danger = BorderToken(
    name: 'border.danger',
    value: Border.fromBorderSide(
      const BorderSide(
        color: Color(0xFFFF4D4F),
        width: BorderScale.thick,
      ),
    ),
  );

  static final List<BorderToken> values = [
    transparent,
    hairline,
    subtle,
    regular,
    strong,
    accent,
    danger,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

/// Helpers.
extension BorderTokenExtension on BorderToken {
  Border copyWith({
    Color? color,
    double? width,
    BorderStyle? style,
  }) {
    final side = value.top;

    return Border.fromBorderSide(
      side.copyWith(
        color: color,
        width: width,
        style: style,
      ),
    );
  }

  BoxDecoration decorate({
    Color? color,
    BorderRadius? borderRadius,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      gradient: gradient,
      border: value,
      borderRadius: borderRadius,
    );
  }

  bool get isTransparent =>
      value.top.color == Colors.transparent;

  bool get isHairline =>
      value.top.width <= BorderScale.hairline;

  bool get isGlass =>
      value.top.color.opacity <= .25;
}