import 'package:flutter/foundation.dart';

/// ===============================================================
/// MetaZone Design System
/// Core Token Engine
/// ===============================================================

@immutable
abstract class DesignToken<T> {
  const DesignToken({
    required this.name,
    required this.value,
    this.description,
    this.isDeprecated = false,
    this.alias,
    this.category,
  });

  final String name;

  final T value;

  final String? description;

  final bool isDeprecated;

  final String? alias;

  final TokenCategory? category;

  DesignToken<T> copyWith({
    String? name,
    T? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  });

  @override
  String toString() =>
      '$runtimeType(name: $name, value: $value)';

  @override
  bool operator ==(Object other) {
    return other is DesignToken<T> &&
        runtimeType == other.runtimeType &&
        name == other.name &&
        value == other.value;
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    value,
  );
}

/// ===============================================================
/// Categories
/// ===============================================================

enum TokenCategory {
  color,
  gradient,
  spacing,
  radius,
  border,
  blur,
  opacity,
  shadow,
  typography,
  duration,
  curve,
  elevation,
  breakpoint,
  icon,
  zIndex,
  animation,
  effect,
  glass,
  semantic,
}

/// ===============================================================
/// Registry
/// ===============================================================

abstract final class DesignTokens {
  DesignTokens._();

  static final Map<String, DesignToken<dynamic>> _tokens = {};

  static void register(
      DesignToken<dynamic> token,
      ) {
    assert(
    !_tokens.containsKey(token.name),
    'Duplicated Design Token: ${token.name}',
    );

    _tokens[token.name] = token;
  }

  static void registerAll(
      Iterable<DesignToken<dynamic>> tokens,
      ) {
    for (final token in tokens) {
      register(token);
    }
  }

  static bool contains(
      String name,
      ) {
    return _tokens.containsKey(name);
  }

  static DesignToken<T> get<T>(
      String name,
      ) {
    final token = _tokens[name];

    if (token == null) {
      throw FlutterError(
        'Design token "$name" does not exist.',
      );
    }

    return token as DesignToken<T>;
  }

  static T value<T>(
      String name,
      ) {
    return get<T>(name).value;
  }

  static List<DesignToken<dynamic>> all() {
    return List.unmodifiable(_tokens.values);
  }

  static List<DesignToken<dynamic>> byCategory(
      TokenCategory category,
      ) {
    return _tokens.values
        .where(
          (e) => e.category == category,
    )
        .toList(
      growable: false,
    );
  }

  static void unregister(
      String name,
      ) {
    _tokens.remove(name);
  }

  static void clear() {
    _tokens.clear();
  }
}

/// ===============================================================
/// Token Groups
/// ===============================================================

@immutable
abstract class DesignTokenGroup {
  const DesignTokenGroup();

  List<DesignToken<dynamic>> get tokens;

  void register() {
    DesignTokens.registerAll(tokens);
  }
}

/// ===============================================================
/// Typed Tokens
/// ===============================================================

@immutable
abstract class ValueToken<T> extends DesignToken<T> {
  const ValueToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
    TokenCategory? category,
  }) : super(
    category: category,
  );
}

@immutable
class GenericToken<T> extends ValueToken<T> {
  const GenericToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
    TokenCategory? category,
  }) : super(
    category: category,
  );

  @override
  GenericToken<T> copyWith({
    String? name,
    T? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return GenericToken<T>(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated:
      isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
      category: category ?? this.category,
    );
  }
}
/// ===============================================================
/// Token Collection
/// ===============================================================

@immutable
class DesignTokenCollection {
  const DesignTokenCollection(
      this.tokens,
      );

  final List<DesignToken<dynamic>> tokens;

  int get length => tokens.length;

  bool get isEmpty => tokens.isEmpty;

  bool get isNotEmpty => tokens.isNotEmpty;

  DesignToken<dynamic> operator [](int index) {
    return tokens[index];
  }

  DesignToken<dynamic>? find(
      String name,
      ) {
    for (final token in tokens) {
      if (token.name == name) {
        return token;
      }
    }

    return null;
  }

  bool contains(
      String name,
      ) {
    return find(name) != null;
  }

  List<DesignToken<dynamic>> whereCategory(
      TokenCategory category,
      ) {
    return tokens
        .where(
          (e) => e.category == category,
    )
        .toList(
      growable: false,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    for (final token in tokens) {
      map[token.name] = token.value;
    }

    return Map.unmodifiable(map);
  }

  List<String> names() {
    return tokens
        .map(
          (e) => e.name,
    )
        .toList(
      growable: false,
    );
  }
}

/// ===============================================================
/// Iterable Extensions
/// ===============================================================

extension DesignTokenIterableExtension
on Iterable<DesignToken<dynamic>> {
  Map<String, dynamic> toTokenMap() {
    final map = <String, dynamic>{};

    for (final token in this) {
      map[token.name] = token.value;
    }

    return Map.unmodifiable(map);
  }

  List<String> tokenNames() {
    return map(
          (e) => e.name,
    ).toList(
      growable: false,
    );
  }

  DesignToken<dynamic>? firstByName(
      String name,
      ) {
    for (final token in this) {
      if (token.name == name) {
        return token;
      }
    }

    return null;
  }
}

/// ===============================================================
/// Debug Utilities
/// ===============================================================

abstract final class DesignTokenDebugger {
  DesignTokenDebugger._();

  static void dump() {
    for (final token in DesignTokens.all()) {
      debugPrint(
        '[${token.category?.name ?? 'uncategorized'}] '
            '${token.name} = ${token.value}',
      );
    }
  }

  static void dumpCategory(
      TokenCategory category,
      ) {
    final list = DesignTokens.byCategory(category);

    for (final token in list) {
      debugPrint(
        '${token.name} = ${token.value}',
      );
    }
  }

  static int total() {
    return DesignTokens.all().length;
  }
}

/// ===============================================================
/// Builder
/// ===============================================================

typedef TokenFactory<T> = DesignToken<T> Function();

abstract final class TokenBuilder {
  TokenBuilder._();

  static DesignToken<T> build<T>(
      TokenFactory<T> factory,
      ) {
    final token = factory();

    DesignTokens.register(token);

    return token;
  }
}

/// ===============================================================
/// Helpers
/// ===============================================================

extension DesignTokenExtension<T> on DesignToken<T> {
  bool get deprecatedValue => isDeprecated;

  bool get hasAlias =>
      alias?.isNotEmpty ?? false;

  bool get hasDescription =>
      description?.isNotEmpty ?? false;

  String get displayCategory =>
      category?.name ?? 'uncategorized';
}