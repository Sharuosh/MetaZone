class NavigationRequest {
  const NavigationRequest({
    required this.routeName,
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, dynamic>{},
    this.extra,
    this.replace = false,
    this.clearStack = false,
  });

  final String routeName;

  final Map<String, String> pathParameters;

  final Map<String, dynamic> queryParameters;

  final Object? extra;

  final bool replace;

  final bool clearStack;

  NavigationRequest copyWith({
    String? routeName,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool? replace,
    bool? clearStack,
  }) {
    return NavigationRequest(
      routeName: routeName ?? this.routeName,
      pathParameters: pathParameters ?? this.pathParameters,
      queryParameters: queryParameters ?? this.queryParameters,
      extra: extra ?? this.extra,
      replace: replace ?? this.replace,
      clearStack: clearStack ?? this.clearStack,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationRequest &&
        other.routeName == routeName &&
        other.pathParameters == pathParameters &&
        other.queryParameters == queryParameters &&
        other.extra == extra &&
        other.replace == replace &&
        other.clearStack == clearStack;
  }

  @override
  int get hashCode => Object.hash(
    routeName,
    pathParameters,
    queryParameters,
    extra,
    replace,
    clearStack,
  );

  @override
  String toString() {
    return 'NavigationRequest('
        'routeName: $routeName, '
        'replace: $replace, '
        'clearStack: $clearStack'
        ')';
  }
}