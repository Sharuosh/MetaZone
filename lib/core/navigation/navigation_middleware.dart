import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

abstract interface class NavigationMiddleware {
  const NavigationMiddleware();

  FutureOr<String?> redirect(
      BuildContext context,
      GoRouterState state,
      );
}