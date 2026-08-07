import 'app_route.dart';

class AppRouteGroup {
  const AppRouteGroup({
    required this.name,
    required this.routes,
    this.initialRouteName,
    this.showInNavigation = false,
    this.maintainState = true,
  });

  final String name;

  final List<AppRoute> routes;

  final String? initialRouteName;

  final bool showInNavigation;

  final bool maintainState;

  AppRoute? get initialRoute {
    if (routes.isEmpty) {
      return null;
    }

    if (initialRouteName == null) {
      return routes.first;
    }

    return routes.firstWhere(
          (route) => route.name == initialRouteName,
      orElse: () => routes.first,
    );
  }
}