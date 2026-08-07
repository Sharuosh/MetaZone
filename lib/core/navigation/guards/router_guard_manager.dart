import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'navigation_guard.dart';

class RouterGuardManager {
  const RouterGuardManager({
    this.guards = const [],
  });

  final List<NavigationGuard> guards;

  String? redirect(
      BuildContext context,
      GoRouterState state,
      ) {
    for (final guard in guards) {
      final result = guard.redirect(
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