import 'package:flutter/widgets.dart';

final class AppLifecycle
    with WidgetsBindingObserver {
  AppLifecycle();

  AppLifecycleState _state =
      AppLifecycleState.resumed;

  AppLifecycleState get state =>
      _state;

  bool get isForeground =>
      _state == AppLifecycleState.resumed;

  bool get isBackground =>
      _state == AppLifecycleState.paused;

  void start() {
    WidgetsBinding.instance.addObserver(
      this,
    );
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(
      this,
    );
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    _state = state;
  }
}