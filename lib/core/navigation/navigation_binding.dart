import 'package:get_it/get_it.dart';

import 'navigation_controller.dart';
import 'navigation_history.dart';
import 'navigation_initializer.dart';
import 'navigation_lifecycle.dart';
import 'navigation_session.dart';
import 'navigation_stack.dart';
import 'navigation_state_notifier.dart';

abstract final class NavigationBinding {
  const NavigationBinding._();

  static void register(
      GetIt getIt,
      ) {
    getIt.registerLazySingleton<NavigationHistory>(
      NavigationHistory.new,
    );

    getIt.registerLazySingleton<NavigationStack>(
      NavigationStack.new,
    );

    getIt.registerLazySingleton<NavigationSession>(
          () => NavigationSession(
        history: getIt<NavigationHistory>(),
        stack: getIt<NavigationStack>(),
      ),
    );

    getIt.registerLazySingleton<NavigationStateNotifier>(
      NavigationStateNotifier.new,
    );

    getIt.registerLazySingleton<NavigationLifecycle>(
      NavigationLifecycle.new,
    );

    getIt.registerLazySingleton<NavigationInitializer>(
          () => NavigationInitializer(
        controller: getIt<NavigationController>(),
        lifecycle: getIt<NavigationLifecycle>(),
        session: getIt<NavigationSession>(),
        stateNotifier: getIt<NavigationStateNotifier>(),
      ),
    );
  }
}