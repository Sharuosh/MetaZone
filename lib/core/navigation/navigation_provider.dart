import 'package:flutter/widgets.dart';

import 'navigation_controller.dart';
import 'navigation_scope.dart';

class NavigationProvider extends StatelessWidget {
  const NavigationProvider({
    super.key,
    required this.controller,
    required this.child,
  });

  final NavigationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NavigationScope(
      controller: controller,
      child: child,
    );
  }
}