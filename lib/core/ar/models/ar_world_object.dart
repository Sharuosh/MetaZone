import 'package:flutter/foundation.dart';

@immutable
class ARWorldObject {
  const ARWorldObject({
    required this.id,
    required this.assetId,
    required this.position,
    this.rotation = const [0, 0, 0],
    this.scale = const [1, 1, 1],
    this.visible = true,
    this.locked = false,
    this.metadata = const {},
  });

  final String id;
  final String assetId;

  final List<double> position;
  final List<double> rotation;
  final List<double> scale;

  final bool visible;
  final bool locked;

  final Map<String, dynamic> metadata;

  ARWorldObject copyWith({
    String? id,
    String? assetId,
    List<double>? position,
    List<double>? rotation,
    List<double>? scale,
    bool? visible,
    bool? locked,
    Map<String, dynamic>? metadata,
  }) {
    return ARWorldObject(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
      metadata: metadata ?? this.metadata,
    );
  }
}