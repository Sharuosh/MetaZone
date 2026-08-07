import 'package:flutter/foundation.dart';

@immutable
class NavigationState {
  const NavigationState({
    required this.currentRoute,
    this.previousRoute,
    this.arguments,
    this.isNavigating = false,
  });

  final String currentRoute;

  final String? previousRoute;

  final Object? arguments;

  final bool isNavigating;

  NavigationState copyWith({
    String? currentRoute,
    String? previousRoute,
    Object? arguments,
    bool? isNavigating,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      previousRoute: previousRoute ?? this.previousRoute,
      arguments: arguments ?? this.arguments,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  static const initial = NavigationState(
    currentRoute: '/',
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NavigationState &&
            runtimeType == other.runtimeType &&
            currentRoute == other.currentRoute &&
            previousRoute == other.previousRoute &&
            arguments == other.arguments &&
            isNavigating == other.isNavigating;
  }

  @override
  int get hashCode => Object.hash(
    currentRoute,
    previousRoute,
    arguments,
    isNavigating,
  );
}