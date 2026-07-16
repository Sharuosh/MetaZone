// lib/world/world_registry.dart

import 'dart:async';

class WorldObject {
  final String id;
  final String type;   // ar_object, portal, sticker, npc ...
  final double x;
  final double y;

  WorldObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
  });
}

class WorldRegistry {
  WorldRegistry._internal();
  static final WorldRegistry instance = WorldRegistry._internal();

  final Map<String, WorldObject> _objects = {};

  final StreamController<List<WorldObject>> _streamController =
  StreamController.broadcast();

  Stream<List<WorldObject>> get stream =>
      _streamController.stream;

  List<WorldObject> get allObjects =>
      _objects.values.toList();

  // ============================
  void add(WorldObject obj) {
    _objects[obj.id] = obj;
    _emit();
  }

  void remove(String id) {
    _objects.remove(id);
    _emit();
  }

  void clear() {
    _objects.clear();
    _emit();
  }

  void _emit() {
    _streamController.add(allObjects);
  }
}
