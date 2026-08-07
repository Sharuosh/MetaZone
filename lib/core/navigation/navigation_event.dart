abstract class NavigationEvent {
  const NavigationEvent({
    required this.timestamp,
  });

  final DateTime timestamp;
}

class NavigationStarted extends NavigationEvent {
  NavigationStarted({
    required super.timestamp,
    required this.route,
  });

  final String route;
}

class NavigationCompleted extends NavigationEvent {
  NavigationCompleted({
    required super.timestamp,
    required this.route,
  });

  final String route;
}

class NavigationCancelled extends NavigationEvent {
  NavigationCancelled({
    required super.timestamp,
    required this.route,
  });

  final String route;
}