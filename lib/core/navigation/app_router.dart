import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_transition.dart';
import 'app_router_config.dart';
import 'models/app_route.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create({
    required List<AppRoute> routes,
    GoRouterRedirect? redirect,
  }) {
    return GoRouter(
      navigatorKey: AppRouterConfig.rootNavigatorKey,
      initialLocation: AppRouterConfig.initialLocation,
      debugLogDiagnostics: AppRouterConfig.debugLogDiagnostics,
      observers: AppRouterConfig.observers,
      redirect: redirect,
      routes: routes.map(_buildRoute).toList(),
    );
  }

  static GoRoute _buildRoute(AppRoute route) {
    return GoRoute(
      name: route.name,
      path: route.path,
      routes: route.children.map(_buildRoute).toList(),
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          maintainState: route.maintainState,
          fullscreenDialog: route.fullScreenDialog,
          transitionDuration: AppRouterConfig.transitionDuration,
          reverseTransitionDuration:
          AppRouterConfig.transitionDuration,
          child: route.builder(
            context,
            state,
          ),
          transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
              ) {
            return AppRouteTransition.buildTransition(
              context,
              animation,
              secondaryAnimation,
              child,
              route.transition,
            );
          },
        );
      },
    );
  }
}