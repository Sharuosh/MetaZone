import '../adapters/ar_engine_adapter.dart';
import '../controllers/ar_placement_controller.dart';
import '../controllers/ar_session_controller.dart';
import '../controllers/ar_ui_controller.dart';

class ARInteractionEngine {
  const ARInteractionEngine({
    required this.session,
    required this.placement,
    required this.ui,
    required this.engine,
  });

  final ARSessionController session;

  final ARPlacementController placement;

  final ARUIController ui;

  final AREngineAdapter engine;

  Future<void> initialize() =>
      session.initialize();

  Future<void> start() =>
      session.start();

  Future<void> pause() =>
      session.pause();

  Future<void> resume() =>
      session.resume();

  Future<void> stop() =>
      session.stop();

  Future<void> beginPlacement() =>
      placement.beginPlacement();

  Future<void> endPlacement() =>
      placement.endPlacement();

  Future<void> updateHitTest({
    required double x,
    required double y,
  }) =>
      placement.updateHitTest(
        x: x,
        y: y,
      );

  Future<void> dispose() async {
    await placement.dispose();
    await ui.dispose();
    await session.dispose();
  }
}