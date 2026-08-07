import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'models/app_route.dart';
import 'navigation_binding.dart';
import 'navigation_initializer.dart';
import 'navigation_module.dart';

abstract final class NavigationBootstrap {
  const NavigationBootstrap._();

  static Future<GoRouter> bootstrap({
    required GetIt getIt,
    required List<AppRoute> routes,
    GoRouterRedirect? redirect,
  }) async {
    await NavigationModule.register(
      getIt: getIt,
      routes: routes,
      redirect: redirect,
    );

    NavigationBinding.register(getIt);

    await getIt<NavigationInitializer>().initialize();

    return getIt<GoRouter>();
  }
}