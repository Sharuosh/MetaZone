import 'package:flutter/foundation.dart';

import 'navigation_state.dart';

class NavigationStateNotifier extends ChangeNotifier {
  NavigationStateNotifier({
    NavigationState? initialState,
  }) : _state = initialState ?? NavigationState.initial;

  NavigationState _state;

  NavigationState get state => _state;

  String get currentRoute => _state.currentRoute;

  String? get previousRoute => _state.previousRoute;

  bool get isNavigating => _state.isNavigating;

  Object? get arguments => _state.arguments;

  void beginNavigation({
    required String route,
    Object? arguments,
  }) {
    _state = _state.copyWith(
      previousRoute: _state.currentRoute,
      currentRoute: route,
      arguments: arguments,
      isNavigating: true,
    );

    notifyListeners();
  }

  void endNavigation() {
    if (!_state.isNavigating) {
      return;
    }

    _state = _state.copyWith(
      isNavigating: false,
    );

    notifyListeners();
  }

  void reset() {
    _state = NavigationState.initial;
    notifyListeners();
  }
}