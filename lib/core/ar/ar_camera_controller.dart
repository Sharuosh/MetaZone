import 'package:flutter/material.dart';
import '../vision/vision_mode.dart';

class ARCameraController extends ChangeNotifier {

  VisionMode visionMode = VisionMode.camera;

  bool isARActive = false;
  bool showGrid = true;
  bool showMiniMap = true;
  bool createModeEnabled = false;

  void toggleAR() {
    isARActive = !isARActive;
    notifyListeners();
  }

  void toggleCreateMode() {
    createModeEnabled = !createModeEnabled;
    notifyListeners();
  }

  void toggleGrid() {
    showGrid = !showGrid;
    notifyListeners();
  }

  void toggleMiniMap() {
    showMiniMap = !showMiniMap;
    notifyListeners();
  }

  void changeVisionMode(VisionMode mode) {
    visionMode = mode;
    notifyListeners();
  }
}
