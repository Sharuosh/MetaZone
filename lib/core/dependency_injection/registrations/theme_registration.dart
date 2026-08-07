import '../../design/theme/controller/metazone_theme_controller.dart';
import '../../design/theme/repository/theme_repository.dart';
import '../../design/theme/service/theme_service.dart';

import '../extensions/get_it_extensions.dart';
import '../service_locator.dart';

final class ThemeRegistration {
  const ThemeRegistration();

  void register() {
    locator.registerLazySingletonIfAbsent<ThemeRepository>(
          () => SharedPreferencesThemeRepository(),
    );

    locator.registerLazySingletonIfAbsent<ThemeService>(
          () => ThemeService(
        repository: locator(),
      ),
    );

    locator.registerLazySingletonIfAbsent<MetaZoneThemeController>(
          () => MetaZoneThemeController(
        service: locator(),
      ),
    );
  }
}