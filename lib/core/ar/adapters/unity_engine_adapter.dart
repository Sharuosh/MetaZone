import 'dart:async';

import '../models/ar_hit_result.dart';
import '../models/ar_world_object.dart';
import 'ar_engine_adapter.dart';

class UnityEngineAdapter implements AREngineAdapter {
  final _sessionReadyController =
  StreamController<bool>.broadcast();

  final _selectedObjectController =
  StreamController<String?>.broadcast();

  final _hitResultController =
  StreamController<ARHitResult?>.broadcast();

  @override
  Stream<bool> get sessionReady =>
      _sessionReadyController.stream;

  @override
  Stream<String?> get selectedObject =>
      _selectedObjectController.stream;

  @override
  Stream<ARHitResult?> get hitResults =>
      _hitResultController.stream;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {
    await _sessionReadyController.close();
    await _selectedObjectController.close();
    await _hitResultController.close();
  }

  @override
  Future<void> startSession() async {}

  @override
  Future<void> pauseSession() async {}

  @override
  Future<void> resumeSession() async {}

  @override
  Future<void> stopSession() async {}

  @override
  Future<void> enableCamera(bool enabled) async {}

  @override
  Future<void> enablePlaneDetection(bool enabled) async {}

  @override
  Future<ARHitResult?> hitTest({
    required double screenX,
    required double screenY,
  }) async {
    return null;
  }

  @override
  Future<void> addObject(ARWorldObject object) async {}

  @override
  Future<void> updateObject(ARWorldObject object) async {}

  @override
  Future<void> removeObject(String objectId) async {}

  @override
  Future<void> clearObjects() async {}

  @override
  Future<void> moveObject({
    required String objectId,
    required List<double> position,
  }) async {}

  @override
  Future<void> rotateObject({
    required String objectId,
    required List<double> rotation,
  }) async {}

  @override
  Future<void> scaleObject({
    required String objectId,
    required List<double> scale,
  }) async {}

  @override
  Future<void> setObjectVisibility({
    required String objectId,
    required bool visible,
  }) async {}

  @override
  Future<void> selectObject(String objectId) async {}

  @override
  Future<void> unselectObject() async {}
}