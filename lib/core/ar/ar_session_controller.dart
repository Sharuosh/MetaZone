import 'package:flutter/material.dart';
import 'enums/vision_mode.dart';
class ARSessionController extends ChangeNotifier {

  /// ================================
  /// VISION MODE
  /// ================================
  VisionMode _visionMode = VisionMode.camera;
  VisionMode get visionMode => _visionMode;

  void changeVisionMode(VisionMode mode) {
    _visionMode = mode;
    notifyListeners();
  }

  /// ================================
  /// AR STATE
  /// ================================
  bool _isARActive = false;
  bool get isARActive => _isARActive;

  void toggleAR() {
    _isARActive = !_isARActive;
    notifyListeners();
  }

  /// ================================
  /// CREATE MODE
  /// ================================
  bool _createModeEnabled = false;
  bool get createModeEnabled => _createModeEnabled;

  void toggleCreateMode() {
    _createModeEnabled = !_createModeEnabled;
    notifyListeners();
  }

  /// ================================
  /// UI STATES
  /// ================================
  bool _showGrid = true;
  bool get showGrid => _showGrid;

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  bool _showMiniMap = true;
  bool get showMiniMap => _showMiniMap;

  void toggleMiniMap() {
    _showMiniMap = !_showMiniMap;
    notifyListeners();
  }

  /// ================================
  /// GHOST PLACEMENT
  /// ================================
  Offset _ghostOffset = Offset.zero;
  double _ghostScale = 1.0;
  double _ghostRotation = 0.0;

  Offset get ghostOffset => _ghostOffset;
  double get ghostScale => _ghostScale;
  double get ghostRotation => _ghostRotation;

  void updateGhostOffset(Offset delta) {
    _ghostOffset += delta;
    notifyListeners();
  }

  void updateGhostScale(double scale) {
    _ghostScale = (_ghostScale * scale).clamp(0.2, 5.0);
    notifyListeners();
  }

  void updateGhostRotation(double delta) {
    _ghostRotation += delta;
    notifyListeners();
  }

  void resetGhost() {
    _ghostOffset = Offset.zero;
    _ghostScale = 1.0;
    _ghostRotation = 0.0;
    notifyListeners();
  }
}
