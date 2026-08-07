import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../guards/auth_guard.dart';
import 'route_transition.dart';

typedef MetaZonePageBuilder = Widget Function(
    BuildContext context,
    GoRouterState state,
    );

class AppRoute {
  const AppRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.children = const [],
    this.requiresAuthentication = false,
    this.requiresOnboarding = false,
    this.showInBottomNavigation = false,
    this.maintainState = true,
    this.fullScreenDialog = false,
    this.transition = RouteTransition.fade,
    this.guard = AuthGuard.none,
  });

  final String name;

  final String path;

  final MetaZonePageBuilder builder;

  final List<AppRoute> children;

  final bool requiresAuthentication;

  final bool requiresOnboarding;

  final bool showInBottomNavigation;

  final bool maintainState;

  final bool fullScreenDialog;

  final RouteTransition transition;

  final AuthGuard guard;
}