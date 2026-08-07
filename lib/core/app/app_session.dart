import 'package:flutter/foundation.dart';

final class AppSession extends ChangeNotifier {
  DateTime _launchTime =
  DateTime.now();

  bool _initialized = false;

  DateTime get launchTime =>
      _launchTime;

  bool get initialized =>
      _initialized;

  Future<void> initialize() async {
    _launchTime = DateTime.now();

    _initialized = true;

    notifyListeners();
  }

  void reset() {
    _initialized = false;

    _launchTime = DateTime.now();

    notifyListeners();
  }
}