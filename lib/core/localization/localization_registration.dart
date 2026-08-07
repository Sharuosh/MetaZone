import 'package:get_it/get_it.dart';

import 'controllers/localization_controller.dart';
import 'repositories/localization_repository.dart';
import 'services/localization_service.dart';

abstract final class LocalizationRegistration {
  const LocalizationRegistration._();

  static Future<void> register(
      GetIt getIt,
      ) async {
    getIt.registerLazySingleton<LocalizationService>(
      LocalizationService.new,
    );

    getIt.registerLazySingleton<LocalizationRepository>(
          () => LocalizationRepository(
        getIt<LocalizationService>(),
      ),
    );

    getIt.registerLazySingleton<LocalizationController>(
          () => LocalizationController(
        getIt<LocalizationRepository>(),
      ),
    );

    await getIt<LocalizationController>().initialize();
  }
}