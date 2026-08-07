import 'dart:async';

import '../adapters/ar_engine_adapter.dart';
import '../enums/ar_session_state.dart';

class ARSessionController {
  ARSessionController(this._engine) {
    _subscription = _engine.sessionReady.listen((ready) {
      _setState(
        ready
            ? ARSessionState.running
            : ARSessionState.initializing,
      );
    });
  }

  final AREngineAdapter _engine;

  late final StreamSubscription<bool> _subscription;

  final StreamController<ARSessionState> _stateController =
  StreamController.broadcast();

  ARSessionState _state = ARSessionState.idle;

  ARSessionState get state => _state;

  Stream<ARSessionState> get stream =>
      _stateController.stream;

  bool get isRunning =>
      _state == ARSessionState.running;

  bool get isReady =>
      _state.isReady;

  Future<void> initialize() async {
    _setState(ARSessionState.initializing);

    try {
      await _engine.initialize();

      _setState(ARSessionState.ready);
    } catch (_) {
      _setState(ARSessionState.failed);
      rethrow;
    }
  }

  Future<void> start() async {
    await _engine.startSession();

    _setState(ARSessionState.running);
  }

  Future<void> pause() async {
    await _engine.pauseSession();

    _setState(ARSessionState.paused);
  }

  Future<void> resume() async {
    await _engine.resumeSession();

    _setState(ARSessionState.running);
  }

  Future<void> stop() async {
    await _engine.stopSession();

    _setState(ARSessionState.stopped);
  }

  void _setState(ARSessionState value) {
    if (_state == value) return;

    _state = value;

    _stateController.add(value);
  }

  Future<void> dispose() async {
    await _subscription.cancel();

    await _engine.dispose();

    await _stateController.close();
  }
}