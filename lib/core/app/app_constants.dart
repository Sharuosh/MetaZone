/// ===============================================================
/// MetaZone Application Constants
/// ===============================================================

abstract final class AppConstants {
  AppConstants._();

  /// Application

  static const String appName = 'MetaZone';

  static const String packageName =
      'com.metazone.app';

  static const String company =
      'MetaZone';

  /// Version

  static const int versionCode = 1;

  static const String versionName =
      '1.0.0';

  /// Locale

  static const String defaultLanguage =
      'en';

  static const String defaultCountry =
      'US';

  /// Timeouts

  static const Duration animationDuration =
  Duration(milliseconds: 300);

  static const Duration splashDuration =
  Duration(milliseconds: 1200);

  static const Duration networkTimeout =
  Duration(seconds: 30);

  /// Cache

  static const Duration memoryCacheLife =
  Duration(minutes: 30);

  static const Duration diskCacheLife =
  Duration(days: 7);

  /// Pagination

  static const int defaultPageSize = 20;

  static const int maxPageSize = 100;

  /// UI

  static const double designWidth =
  390;

  static const double designHeight =
  844;

  static const double tabletBreakpoint =
  768;

  static const double desktopBreakpoint =
  1200;
}