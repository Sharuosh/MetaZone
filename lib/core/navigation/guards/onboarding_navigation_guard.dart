import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../app_route_paths.dart';
import 'navigation_guard.dart';

class OnboardingNavigationGuard implements NavigationGuard {
  const OnboardingNavigationGuard({
    required this.hasCompletedOnboarding,
  });

  final bool Function() hasCompletedOnboarding;

  @override
  String? redirect(
      BuildContext context,
      GoRouterState state,
      ) {
    final completed = hasCompletedOnboarding();

    final location = state.matchedLocation;

    if (!completed) {
      if (location == AppRoutePaths.onboarding) {
        return null;
      }

      return AppRoutePaths.onboarding;
    }

    if (location == AppRoutePaths.onboarding) {
      return AppRoutePaths.home;
    }

    return null;
  }
}