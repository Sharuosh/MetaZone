import '../models/ar_hit_result.dart';
import '../models/ar_world_object.dart';

abstract interface class AREngineAdapter {
  /// Lifecycle

  Future<void> initialize();

  Future<void> dispose();

  /// Session

  Future<void> startSession();

  Future<void> pauseSession();

  Future<void> resumeSession();

  Future<void> stopSession();

  /// Camera

  Future<void> enableCamera(bool enabled);

  /// Plane Detection

  Future<void> enablePlaneDetection(bool enabled);

  /// Hit Test

  Future<ARHitResult?> hitTest({
    required double screenX,
    required double screenY,
  });

  /// Objects

  Future<void> addObject(ARWorldObject object);

  Future<void> updateObject(ARWorldObject object);

  Future<void> removeObject(String objectId);

  Future<void> clearObjects();

  /// Transform

  Future<void> moveObject({
    required String objectId,
    required List<double> position,
  });

  Future<void> rotateObject({
    required String objectId,
    required List<double> rotation,
  });

  Future<void> scaleObject({
    required String objectId,
    required List<double> scale,
  });

  /// Visibility

  Future<void> setObjectVisibility({
    required String objectId,
    required bool visible,
  });

  /// Selection

  Future<void> selectObject(String objectId);

  Future<void> unselectObject();

  /// Events

  Stream<bool> get sessionReady;

  Stream<String?> get selectedObject;

  Stream<ARHitResult?> get hitResults;
}