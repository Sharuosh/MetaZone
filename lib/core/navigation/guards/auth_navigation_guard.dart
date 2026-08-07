import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app_route_paths.dart';
import 'navigation_guard.dart';

class AuthNavigationGuard implements NavigationGuard {
  const AuthNavigationGuard({
    required this.isAuthenticated,
  });

  final bool Function() isAuthenticated;

  @override
  String? redirect(
      BuildContext context,
      GoRouterState state,
      ) {
    if (isAuthenticated()) {
      return null;
    }

    final location = state.matchedLocation;

    if (location == AppRoutePaths.login ||
        location == AppRoutePaths.register ||
        location == AppRoutePaths.forgotPassword ||
        location == AppRoutePaths.onboarding) {
      return null;
    }

    return AppRoutePaths.login;
  }
}