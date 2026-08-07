import 'package:flutter/foundation.dart';

class NavigationLifecycle extends ChangeNotifier {
  bool _initialized = false;
  bool _disposed = false;

  bool get isInitialized => _initialized;

  bool get isDisposed => _disposed;

  void initialize() {
    if (_initialized) {
      return;
    }

    _initialized = true;
    notifyListeners();
  }

  void reset() {
    _initialized = false;
    _disposed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    super.dispose();
  }
}