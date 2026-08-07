import 'app_environment.dart';

final class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogs,
    required this.enableAnalytics,
  });

  final AppEnvironment environment;

  final String apiBaseUrl;

  final bool enableLogs;

  final bool enableAnalytics;

  bool get isProduction =>
      environment.isProduction;

  bool get isDevelopment =>
      environment.isDevelopment;
}