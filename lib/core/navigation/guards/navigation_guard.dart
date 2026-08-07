import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract interface class NavigationGuard {
  const NavigationGuard();

  String? redirect(
      BuildContext context,
      GoRouterState state,
      );
}