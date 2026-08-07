import 'navigation_event.dart';
import 'navigation_listener.dart';

class NavigationDispatcher {
  final List<NavigationListener> _listeners = [];

  void addListener(
      NavigationListener listener,
      ) {
    if (_listeners.contains(listener)) {
      return;
    }

    _listeners.add(listener);
  }

  void removeListener(
      NavigationListener listener,
      ) {
    _listeners.remove(listener);
  }

  void dispatch(
      NavigationEvent event,
      ) {
    for (final listener in List<NavigationListener>.from(_listeners)) {
      listener(event);
    }
  }

  void clear() {
    _listeners.clear();
  }
}