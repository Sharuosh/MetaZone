import '../dependency_injection/locator.dart';
import 'app_session.dart';

/// Initializes the application before runApp().
final class AppInitializer {
  AppInitializer._();

  static Future<AppSession> initialize() async {
    // Initialize dependency injection.
    await setupLocator();

    // Initialize app session.
    final session = AppSession();
    await session.initialize();

    return session;
  }
}