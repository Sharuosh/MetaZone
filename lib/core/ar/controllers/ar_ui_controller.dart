import 'dart:async';

import '../enums/vision_mode.dart';

class ARUIController {
  final StreamController<VisionMode> _controller =
  StreamController.broadcast();

  VisionMode _mode = VisionMode.ar;

  Stream<VisionMode> get stream => _controller.stream;

  VisionMode get mode => _mode;

  bool get isCreator =>
      _mode == VisionMode.creator;

  bool get isNavigation =>
      _mode == VisionMode.navigation;

  bool get isCamera =>
      _mode == VisionMode.camera;

  void setMode(VisionMode mode) {
    if (_mode == mode) return;

    _mode = mode;

    _controller.add(mode);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}