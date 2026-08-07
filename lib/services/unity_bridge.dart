// lib/services/unity_bridge.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class UnityBridge {
  UnityBridge._();

  static final UnityBridge instance = UnityBridge._();

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void attach() {
    _isConnected = true;
    debugPrint("UnityBridge: Connected");
  }

  void detach() {
    _isConnected = false;
    debugPrint("UnityBridge: Disconnected");
  }

  void sendMessage({
    required String objectName,
    required String methodName,
    required String message,
  }) {
    if (!_isConnected) {
      debugPrint("UnityBridge: Unity is not connected.");
      return;
    }

    sendToUnity(
      objectName,
      methodName,
      message,
    );
  }

  // ==========================
  // Assets
  // ==========================

  void selectAsset(String assetId) {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "SelectAsset",
      message: assetId,
    );
  }

  // ==========================
  // Scene
  // ==========================

  void clearScene() {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "ClearScene",
      message: "",
    );
  }

  void saveScene() {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "SaveScene",
      message: "",
    );
  }

  void loadScene() {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "LoadScene",
      message: "",
    );
  }

  // ==========================
  // Objects
  // ==========================

  void deleteSelected() {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "DeleteSelected",
      message: "",
    );
  }

  void duplicateSelected() {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "DuplicateSelected",
      message: "",
    );
  }

  void rotateSelected(double angle) {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "RotateSelected",
      message: angle.toString(),
    );
  }

  void scaleSelected(double scale) {
    sendMessage(
      objectName: "FlutterBridge",
      methodName: "ScaleSelected",
      message: scale.toString(),
    );
  }
}