import 'navigation_controller.dart';
import 'navigation_lifecycle.dart';
import 'navigation_session.dart';
import 'navigation_state_notifier.dart';

class NavigationInitializer {
  NavigationInitializer({
    required this.controller,
    required this.lifecycle,
    required this.session,
    required this.stateNotifier,
  });

  final NavigationController controller;
  final NavigationLifecycle lifecycle;
  final NavigationSession session;
  final NavigationStateNotifier stateNotifier;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    lifecycle.initialize();

    final route = controller.currentRoute;

    if (route.isNotEmpty) {
      session.push(route);

      stateNotifier.beginNavigation(
        route: route,
      );

      stateNotifier.endNavigation();
    }

    _initialized = true;
  }

  void dispose() {
    session.reset();
    stateNotifier.reset();
    lifecycle.dispose();
    _initialized = false;
  }
}