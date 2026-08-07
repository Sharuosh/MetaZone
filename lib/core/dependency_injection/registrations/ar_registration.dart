import 'package:get_it/get_it.dart';

import '../../ar/adapters/ar_engine_adapter.dart';
import '../../ar/adapters/unity_engine_adapter.dart';
import '../../ar/controllers/ar_placement_controller.dart';
import '../../ar/controllers/ar_session_controller.dart';
import '../../ar/controllers/ar_ui_controller.dart';
import '../../ar/engine/ar_gesture_controller.dart';
import '../../ar/engine/ar_hit_test_service.dart';
import '../../ar/engine/ar_interaction_engine.dart';

final class ARRegistration {
  const ARRegistration();

  void register() {
    final getIt = GetIt.instance;

    if (!getIt.isRegistered<AREngineAdapter>()) {
      getIt.registerLazySingleton<AREngineAdapter>(
        UnityEngineAdapter.new,
      );
    }

    if (!getIt.isRegistered<ARSessionController>()) {
      getIt.registerLazySingleton(
            () => ARSessionController(
          getIt<AREngineAdapter>(),
        ),
      );
    }

    if (!getIt.isRegistered<ARPlacementController>()) {
      getIt.registerLazySingleton(
            () => ARPlacementController(
          getIt<AREngineAdapter>(),
        ),
      );
    }

    if (!getIt.isRegistered<ARUIController>()) {
      getIt.registerLazySingleton(
        ARUIController.new,
      );
    }

    if (!getIt.isRegistered<ARHitTestService>()) {
      getIt.registerLazySingleton(
            () => ARHitTestService(
          getIt<AREngineAdapter>(),
        ),
      );
    }

    if (!getIt.isRegistered<ARGestureController>()) {
      getIt.registerLazySingleton(
        ARGestureController.new,
      );
    }

    if (!getIt.isRegistered<ARInteractionEngine>()) {
      getIt.registerLazySingleton(
            () => ARInteractionEngine(
          session: getIt(),
          placement: getIt(),
          ui: getIt(),
          engine: getIt(),
        ),
      );
    }
  }
}