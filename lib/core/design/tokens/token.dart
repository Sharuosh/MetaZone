import 'package:flutter/foundation.dart';

import 'design_token.dart';

/// Base implementation for all strongly typed design tokens.
///
/// Every specialized token (ColorToken, RadiusToken, etc.)
/// extends from this class.
@immutable
abstract class Token<T> extends ValueToken<T> {
  const Token({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
    required TokenCategory category,
  }) : super(
    category: category,
  );

  @override
  Token<T> copyWith({
    String? name,
    T? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  });
}

/// Generic token implementation.
///
/// Useful when you don't need a dedicated subclass.
@immutable
class BaseToken<T> extends Token<T> {
  const BaseToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
    required super.category,
  });

  @override
  BaseToken<T> copyWith({
    String? name,
    T? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return BaseToken<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
      category: category ?? this.category!,
    );
  }
}

/// Utility extensions.
extension TokenExtension<T> on Token<T> {
  bool get isAlias => alias?.isNotEmpty ?? false;

  bool get isActive => !isDeprecated;

  String get label => name.replaceAll('.', ' › ');
}