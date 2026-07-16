import 'package:flutter/foundation.dart';

enum ARTrackingState {
  idle,
  initializing,
  tracking,
  lost,
  error,
}

class ARRuntimeController extends ChangeNotifier {
  ARTrackingState _trackingState = ARTrackingState.idle;
  bool _placementMode = false;
  String? _selectedObjectId;

  ARTrackingState get trackingState => _trackingState;
  bool get placementMode => _placementMode;
  String? get selectedObjectId => _selectedObjectId;

  void setTrackingState(ARTrackingState state) {
    _trackingState = state;
    notifyListeners();
  }

  void enablePlacement(String objectId) {
    _placementMode = true;
    _selectedObjectId = objectId;
    notifyListeners();
  }

  void disablePlacement() {
    _placementMode = false;
    _selectedObjectId = null;
    notifyListeners();
  }

  void reset() {
    _trackingState = ARTrackingState.idle;
    _placementMode = false;
    _selectedObjectId = null;
    notifyListeners();
  }
}
