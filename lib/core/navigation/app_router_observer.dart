import 'package:flutter/widgets.dart';

class AppRouterObserver extends NavigatorObserver {
  AppRouterObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('PUSH', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('POP', route, previousRoute);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    super.didReplace(
      newRoute: newRoute,
      oldRoute: oldRoute,
    );

    debugPrint(
      '[ROUTER] REPLACE '
          '${oldRoute?.settings.name ?? oldRoute.runtimeType}'
          ' -> '
          '${newRoute?.settings.name ?? newRoute.runtimeType}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('REMOVE', route, previousRoute);
  }

  void _log(
      String action,
      Route<dynamic>? route,
      Route<dynamic>? previousRoute,
      ) {
    debugPrint(
      '[ROUTER] $action '
          '${route?.settings.name ?? route.runtimeType}'
          ' <- '
          '${previousRoute?.settings.name ?? previousRoute.runtimeType}',
    );
  }
}