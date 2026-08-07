import 'navigation_event.dart';

abstract class NavigationAnalytics {
  const NavigationAnalytics();

  Future<void> track(
      NavigationEvent event,
      );
}