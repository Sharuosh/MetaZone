enum ARSessionState {
  idle,

  initializing,

  ready,

  running,

  paused,

  interrupted,

  relocalizing,

  stopped,

  failed,
}

extension ARSessionStateX on ARSessionState {
  bool get isActive =>
      this == ARSessionState.running;

  bool get isReady =>
      this == ARSessionState.ready ||
          this == ARSessionState.running;

  bool get isStopped =>
      this == ARSessionState.stopped;

  bool get hasError =>
      this == ARSessionState.failed;

  bool get isInitializing =>
      this == ARSessionState.initializing;

  bool get isPaused =>
      this == ARSessionState.paused;

  bool get needsRelocalization =>
      this == ARSessionState.relocalizing;
}