import 'package:flutter/widgets.dart';

import 'navigation_controller.dart';

class NavigationScope extends InheritedWidget {
  const NavigationScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final NavigationController controller;

  static NavigationController of(BuildContext context) {
    final scope =
    context.dependOnInheritedWidgetOfExactType<NavigationScope>();

    assert(
    scope != null,
    'NavigationScope not found in widget tree.',
    );

    return scope!.controller;
  }

  static NavigationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NavigationScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(
      NavigationScope oldWidget,
      ) {
    return controller != oldWidget.controller;
  }
}