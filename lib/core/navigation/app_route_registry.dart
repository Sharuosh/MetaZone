import 'models/app_route.dart';
import 'models/app_route_group.dart';

class AppRouteRegistry {
  const AppRouteRegistry({
    this.groups = const [],
  });

  final List<AppRouteGroup> groups;

  List<AppRoute> get allRoutes {
    return groups
        .expand(
          (group) => group.routes,
    )
        .toList(growable: false);
  }

  AppRoute? findByName(String name) {
    for (final route in allRoutes) {
      if (route.name == name) {
        return route;
      }
    }

    return null;
  }

  AppRoute? findByPath(String path) {
    for (final route in allRoutes) {
      if (route.path == path) {
        return route;
      }
    }

    return null;
  }

  bool contains(String name) {
    return findByName(name) != null;
  }
}