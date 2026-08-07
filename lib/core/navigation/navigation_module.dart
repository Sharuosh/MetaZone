import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'navigation_controller.dart';
import 'navigation_service.dart';
import 'models/app_route.dart';

abstract final class NavigationModule {
  const NavigationModule._();

  static Future<void> register({
    required GetIt getIt,
    required List<AppRoute> routes,
    GoRouterRedirect? redirect,
  }) async {
    final router = AppRouter.create(
      routes: routes,
      redirect: redirect,
    );

    getIt.registerLazySingleton<GoRouter>(
          () => router,
    );

    getIt.registerLazySingleton<NavigationService>(
          () => NavigationService(
        router: getIt<GoRouter>(),
      ),
    );

    getIt.registerLazySingleton<NavigationController>(
          () => NavigationController(
        service: getIt<NavigationService>(),
      ),
    );
  }
}