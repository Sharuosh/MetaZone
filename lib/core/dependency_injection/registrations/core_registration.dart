import '../service_locator.dart';

/// ===============================================================
/// MetaZone Core Registration
/// ===============================================================
///
/// Registers core-level services used across the application.
///
/// Rules:
/// • Register only infrastructure/core services.
/// • Never register feature modules here.
/// • Every registration must be idempotent.
/// • Never overwrite existing registrations.
///
/// ===============================================================

final class CoreRegistration {
  const CoreRegistration();

  void register() {
    _registerCoreServices();
  }

  void _registerCoreServices() {
    //
    // Register global core services here.
    //
    // Examples in the future:
    //
    // - Logger
    // - Crash Reporter
    // - Analytics
    // - Environment
    // - Connectivity
    // - Device Info
    // - App Info
    // - Permission Manager
    // - Lifecycle Manager
    //
  }

  /// Registers a lazy singleton safely.
  void registerLazySingleton<T extends Object>(
      T Function() factory,
      ) {
    if (locator.isRegistered<T>()) {
      return;
    }

    locator.registerLazySingleton<T>(
      factory,
    );
  }

  /// Registers a singleton safely.
  void registerSingleton<T extends Object>(
      T instance,
      ) {
    if (locator.isRegistered<T>()) {
      return;
    }

    locator.registerSingleton<T>(
      instance,
    );
  }

  /// Registers a factory safely.
  void registerFactory<T extends Object>(
      T Function() factory,
      ) {
    if (locator.isRegistered<T>()) {
      return;
    }

    locator.registerFactory<T>(
      factory,
    );
  }
}