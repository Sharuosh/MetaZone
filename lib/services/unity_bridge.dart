import 'package:flutter/foundation.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

/// MetaZone Flutter -> Unity command gateway.
///
/// Keeps the existing public commands and adds the AR placement/editing
/// contract used by the V1 Object flow.
class UnityBridge {
  UnityBridge._();

  static final UnityBridge instance = UnityBridge._();

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void attach() {
    _isConnected = true;
    debugPrint('UnityBridge: Connected');
  }

  void detach() {
    _isConnected = false;
    debugPrint('UnityBridge: Disconnected');
  }

  void sendMessage({
    required String objectName,
    required String methodName,
    required String message,
  }) {
    if (!_isConnected) {
      debugPrint('UnityBridge: Unity is not connected.');
      return;
    }

    sendToUnity(objectName, methodName, message);
  }

  void selectAsset(String assetId) => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'SelectAsset',
    message: assetId,
  );

  void startSurfaceScan() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'StartSurfaceScan',
    message: '',
  );

  void placeObject() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'PlaceObject',
    message: '',
  );

  void cancelPlacement() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'CancelPlacement',
    message: '',
  );

  void clearScene() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'ClearScene',
    message: '',
  );

  void saveScene() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'SaveScene',
    message: '',
  );

  void loadScene() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'LoadScene',
    message: '',
  );

  void deleteSelected() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'DeleteSelected',
    message: '',
  );

  void duplicateSelected() => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'DuplicateSelected',
    message: '',
  );

  void moveSelected(double x, double y, double z) => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'MoveSelected',
    message: '$x,$y,$z',
  );

  void rotateSelected(double angle) => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'RotateSelected',
    message: angle.toString(),
  );

  void scaleSelected(double scale) => sendMessage(
    objectName: 'FlutterBridge',
    methodName: 'ScaleSelected',
    message: scale.toString(),
  );
}
