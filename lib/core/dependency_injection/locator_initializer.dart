import 'registrations/ar_registration.dart';
import 'registrations/core_registration.dart';
import 'registrations/theme_registration.dart';

final class LocatorInitializer {
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    const CoreRegistration().register();
    const ThemeRegistration().register();
    const ARRegistration().register();

    _initialized = true;
  }
}
