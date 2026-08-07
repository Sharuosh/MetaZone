import 'package:flutter/foundation.dart';

import 'models/navigation_request.dart';
import 'models/navigation_result.dart';
import 'navigation_service.dart';

/// High-level controller responsible for coordinating navigation.
///
/// This class should contain navigation business rules while
/// [NavigationService] communicates directly with GoRouter.
class NavigationController {
  NavigationController({
    required NavigationService service,
  }) : _service = service {
    _syncLocation();
  }

  final NavigationService _service;

  /// Exposes the current route for listeners.
  final ValueNotifier<String> currentLocation =
  ValueNotifier<String>('/');

  //----------------------------------------------------------------------------
  // Navigation
  //----------------------------------------------------------------------------

  void go(NavigationRequest request) {
    _service.go(request);
    _syncLocation();
  }

  Future<void> push(NavigationRequest request) async {
    await _service.push(request);
    _syncLocation();
  }

  void replace(NavigationRequest request) {
    _service.replace(request);
    _syncLocation();
  }

  Future<NavigationResult<T?>> pushForResult<T>(
      NavigationRequest request,
      ) {
    return _service.pushForResult<T>(request);
  }

  //----------------------------------------------------------------------------
  // Back Navigation
  //----------------------------------------------------------------------------

  void pop<T extends Object?>([T? result]) {
    _service.pop(result);
    _syncLocation();
  }

  bool canPop() {
    return _service.canPop();
  }

  //----------------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------------

  String get currentRoute => currentLocation.value;

  void refresh() {
    _syncLocation();
  }

  //----------------------------------------------------------------------------
  // Internal
  //----------------------------------------------------------------------------

  void _syncLocation() {
    currentLocation.value = _service.location;
  }

  void dispose() {
    currentLocation.dispose();
  }
}