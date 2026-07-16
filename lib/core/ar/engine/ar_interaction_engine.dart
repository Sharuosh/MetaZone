import 'package:flutter/material.dart';
import 'ar_hit_test_service.dart';

enum ARInteractionState {
  idle,
  hitTesting,
  objectFocused,
  objectSelected,
  placementMode,
  dragging,
  scaling,
  panelOpen,
}

class ARInteractionEngine extends ChangeNotifier {
  final ARHitTestService _hitTestService;

  ARInteractionEngine({ARHitTestService? hitTestService})
      : _hitTestService = hitTestService ?? ARHitTestService();

  // =========================
  // INTERNAL STATE
  // =========================

  ARInteractionState _state = ARInteractionState.idle;
  Offset? _lastHitPoint;
  String? _selectedObjectId;

  // =========================
  // GETTERS
  // =========================

  ARInteractionState get state => _state;
  Offset? get lastHitPoint => _lastHitPoint;
  String? get selectedObjectId => _selectedObjectId;

  bool get isPlacing => _state == ARInteractionState.placementMode;
  bool get isPanelOpen => _state == ARInteractionState.panelOpen;

  // =========================
  // STATE CONTROL
  // =========================

  void _setState(ARInteractionState newState) {
    if (_state == newState) return;
    _state = newState;
    notifyListeners();
  }

  void reset() {
    _selectedObjectId = null;
    _lastHitPoint = null;
    _setState(ARInteractionState.idle);
  }

  // =========================
  // HIT TEST FLOW
  // =========================

  void handleTap(Offset position, Size screenSize) {
    _setState(ARInteractionState.hitTesting);

    final result = _hitTestService.hitTest(
      tapPosition: position,
      screenSize: screenSize,
    );

    if (result.isValid) {
      _lastHitPoint = result.screenPosition;
      _setState(ARInteractionState.objectFocused);
    }

  }

  // =========================
  // OBJECT SELECTION
  // =========================

  void selectObject(String objectId) {
    _selectedObjectId = objectId;
    _setState(ARInteractionState.objectSelected);
  }

  void openPanel() {
    if (_selectedObjectId == null) return;
    _setState(ARInteractionState.panelOpen);
  }

  void closePanel() {
    _setState(ARInteractionState.objectSelected);
  }

  // =========================
  // PLACEMENT FLOW
  // =========================

  void startPlacement() {
    _selectedObjectId = null;
    _setState(ARInteractionState.placementMode);
  }

  void confirmPlacement() {
    _setState(ARInteractionState.idle);
  }

  void cancelPlacement() {
    reset();
  }

  // =========================
  // GESTURE STATES
  // =========================

  void startDragging() {
    _setState(ARInteractionState.dragging);
  }

  void startScaling() {
    _setState(ARInteractionState.scaling);
  }

  void endGesture() {
    _setState(ARInteractionState.objectSelected);
  }
}
