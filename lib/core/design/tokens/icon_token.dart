import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class IconToken extends Token<IconData> {
  const IconToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.icon,
  );

  @override
  IconToken copyWith({
    String? name,
    IconData? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return IconToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  Icon build({
    Color? color,
    double? size,
    String? semanticLabel,
    TextDirection? textDirection,
  }) {
    return Icon(
      value,
      color: color,
      size: size,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
  }
}

abstract final class IconScale {
  IconScale._();

  static const tiny = 12.0;
  static const xSmall = 14.0;
  static const small = 16.0;
  static const medium = 20.0;
  static const regular = 24.0;
  static const large = 28.0;
  static const xLarge = 32.0;
  static const xxLarge = 40.0;
  static const huge = 48.0;
  static const massive = 56.0;
  static const giant = 64.0;
}

abstract final class IconTokens {
  IconTokens._();

  static final tiny = BaseToken<double>(
    name: 'icon.size.tiny',
    value: IconScale.tiny,
    category: TokenCategory.icon,
  );

  static final xSmall = BaseToken<double>(
    name: 'icon.size.xSmall',
    value: IconScale.xSmall,
    category: TokenCategory.icon,
  );

  static final small = BaseToken<double>(
    name: 'icon.size.small',
    value: IconScale.small,
    category: TokenCategory.icon,
  );

  static final medium = BaseToken<double>(
    name: 'icon.size.medium',
    value: IconScale.medium,
    category: TokenCategory.icon,
  );

  static final regular = BaseToken<double>(
    name: 'icon.size.regular',
    value: IconScale.regular,
    category: TokenCategory.icon,
  );

  static final large = BaseToken<double>(
    name: 'icon.size.large',
    value: IconScale.large,
    category: TokenCategory.icon,
  );

  static final xLarge = BaseToken<double>(
    name: 'icon.size.xLarge',
    value: IconScale.xLarge,
    category: TokenCategory.icon,
  );

  static final xxLarge = BaseToken<double>(
    name: 'icon.size.xxLarge',
    value: IconScale.xxLarge,
    category: TokenCategory.icon,
  );

  static final huge = BaseToken<double>(
    name: 'icon.size.huge',
    value: IconScale.huge,
    category: TokenCategory.icon,
  );

  static final massive = BaseToken<double>(
    name: 'icon.size.massive',
    value: IconScale.massive,
    category: TokenCategory.icon,
  );

  static final giant = BaseToken<double>(
    name: 'icon.size.giant',
    value: IconScale.giant,
    category: TokenCategory.icon,
  );

  static final List<DesignToken<dynamic>> values = [
    tiny,
    xSmall,
    small,
    medium,
    regular,
    large,
    xLarge,
    xxLarge,
    huge,
    massive,
    giant,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension IconTokenExtension on IconToken {
  Icon icon({
    Color? color,
    double? size,
  }) {
    return build(
      color: color,
      size: size,
    );
  }

  bool get isDirectional =>
      value.matchTextDirection;

  int get codePoint =>
      value.codePoint;

  String get fontFamily =>
      value.fontFamily ?? '';

  String? get fontPackage =>
      value.fontPackage;
}