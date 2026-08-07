import '../adapters/ar_engine_adapter.dart';
import '../models/ar_hit_result.dart';

class ARHitTestService {
  const ARHitTestService(this._engine);

  final AREngineAdapter _engine;

  Future<ARHitResult?> hitTest({
    required double x,
    required double y,
  }) {
    return _engine.hitTest(
      screenX: x,
      screenY: y,
    );
  }
}