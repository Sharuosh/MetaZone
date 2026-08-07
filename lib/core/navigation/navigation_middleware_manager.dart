import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'navigation_middleware.dart';

class NavigationMiddlewareManager {
  NavigationMiddlewareManager({
    this.middlewares = const [],
  });

  final List<NavigationMiddleware> middlewares;

  Future<String?> execute(
      BuildContext context,
      GoRouterState state,
      ) async {
    for (final middleware in middlewares) {
      final result = await middleware.redirect(
        context,
        state,
      );

      if (result != null) {
        return result;
      }
    }

    return null;
  }
}