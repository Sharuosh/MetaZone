import 'dart:async';

import '../adapters/ar_engine_adapter.dart';
import '../models/ar_hit_result.dart';
import '../models/ar_placement_state.dart';

class ARPlacementController {
  ARPlacementController(this._engine) {
    _subscription = _engine.hitResults.listen((hit) {
      _update(
        _state.copyWith(
          hitResult: hit,
        ),
      );
    });
  }

  final AREngineAdapter _engine;

  late final StreamSubscription<ARHitResult?> _subscription;

  final StreamController<ARPlacementState> _controller =
  StreamController.broadcast();

  ARPlacementState _state = const ARPlacementState();

  Stream<ARPlacementState> get stream => _controller.stream;

  ARPlacementState get state => _state;

  bool get isPlacing => _state.isPlacing;

  Future<void> beginPlacement() async {
    _update(
      _state.copyWith(
        isPlacing: true,
        previewVisible: true,
      ),
    );
  }

  Future<void> endPlacement() async {
    _update(
      _state.copyWith(
        isPlacing: false,
        previewVisible: false,
      ),
    );
  }

  Future<void> updateHitTest({
    required double x,
    required double y,
  }) async {
    final result = await _engine.hitTest(
      screenX: x,
      screenY: y,
    );

    _update(
      _state.copyWith(
        hitResult: result,
      ),
    );
  }

  void _update(ARPlacementState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }
}