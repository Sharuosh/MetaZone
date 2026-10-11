abstract final class NavigationConstants {
  const NavigationConstants._();

  static const String initialLocation = '/';

  static const Duration transitionDuration = Duration(
    milliseconds: 250,
  );

  static const Duration reverseTransitionDuration = Duration(
    milliseconds: 250,
  );

  static const bool debugLogDiagnostics = false;

  static const bool requestFocus = true;

  static const bool maintainState = true;

  static const bool fullscreenDialog = false;

  static const String defaultUnknownRoute = '/404';

  static const String defaultHomeRoute = '/home1';

  static const String defaultLoginRoute = '/login';

  static const String defaultOnboardingRoute = '/onboarding';

  static const String defaultSplashRoute = '/';

  static const int maxRedirectCount = 10;
}