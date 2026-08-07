import 'package:go_router/go_router.dart';

import 'models/navigation_request.dart';
import 'models/navigation_result.dart';

/// Central service responsible for all navigation operations.
///
/// This is the only layer that communicates directly with GoRouter.
class NavigationService {
  NavigationService({
    required GoRouter router,
  }) : _router = router;

  final GoRouter _router;

  GoRouter get router => _router;

  //----------------------------------------------------------------------------
  // Navigation
  //----------------------------------------------------------------------------

  void go(NavigationRequest request) {
    _router.goNamed(
      request.routeName,
      pathParameters: request.pathParameters,
      queryParameters: request.queryParameters,
      extra: request.extra,
    );
  }

  Future<void> push(NavigationRequest request) {
    return _router.pushNamed<void>(
      request.routeName,
      pathParameters: request.pathParameters,
      queryParameters: request.queryParameters,
      extra: request.extra,
    );
  }

  void replace(NavigationRequest request) {
    _router.replaceNamed(
      request.routeName,
      pathParameters: request.pathParameters,
      queryParameters: request.queryParameters,
      extra: request.extra,
    );
  }

  Future<NavigationResult<T?>> pushForResult<T>(
      NavigationRequest request,
      ) async {
    final result = await _router.pushNamed<T>(
      request.routeName,
      pathParameters: request.pathParameters,
      queryParameters: request.queryParameters,
      extra: request.extra,
    );

    return NavigationResult<T?>(
      value: result,
      cancelled: result == null,
    );
  }

  //----------------------------------------------------------------------------
  // Back Navigation
  //----------------------------------------------------------------------------

  void pop<T extends Object?>([T? result]) {
    if (!canPop()) return;

    _router.pop(result);
  }

  void goBack() => pop();

  bool canPop() => _router.canPop();

  //----------------------------------------------------------------------------
  // Location
  //----------------------------------------------------------------------------

  String get location =>
      _router.routeInformationProvider.value.uri.toString();
}