import 'package:flutter/foundation.dart';

import 'navigation_event.dart';

class NavigationLogger {
  const NavigationLogger();

  void log(
      NavigationEvent event,
      ) {
    debugPrint(
      '[Navigation] '
          '${event.runtimeType} '
          '${event.timestamp.toIso8601String()}',
    );
  }
}