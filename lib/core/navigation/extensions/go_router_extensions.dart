import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension GoRouterContextExtension on BuildContext {
  GoRouter get router => GoRouter.of(this);

  void goTo(
      String location, {
        Object? extra,
      }) {
    router.go(
      location,
      extra: extra,
    );
  }

  void pushTo(
      String location, {
        Object? extra,
      }) {
    router.push(
      location,
      extra: extra,
    );
  }

  void replaceWith(
      String location, {
        Object? extra,
      }) {
    router.replace(
      location,
      extra: extra,
    );
  }

  void goNamedRoute(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) {
    router.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void pushNamedRoute(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) {
    router.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void replaceNamedRoute(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, dynamic> queryParameters = const {},
        Object? extra,
      }) {
    router.replaceNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void popRoute<T extends Object?>([T? result]) {
    if (canPop()) {
      pop(result);
    }
  }

  bool canPopRoute() {
    return canPop();
  }
}