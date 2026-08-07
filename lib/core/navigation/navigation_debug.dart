import 'package:flutter/foundation.dart';

abstract final class NavigationDebug {
  const NavigationDebug._();

  static void log(
      Object message,
      ) {
    if (kDebugMode) {
      debugPrint(
        '[Navigation] $message',
      );
    }
  }
}