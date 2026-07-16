enum ARInteractionMode {
  idle,
  focusing,
  selected,
  panelOpen,
  placing,
}

class ARInteractionState {
  final ARInteractionMode mode;
  final String? focusedObjectId;
  final String? selectedObjectId;

  const ARInteractionState({
    this.mode = ARInteractionMode.idle,
    this.focusedObjectId,
    this.selectedObjectId,
  });

  ARInteractionState copyWith({
    ARInteractionMode? mode,
    String? focusedObjectId,
    String? selectedObjectId,
  }) {
    return ARInteractionState(
      mode: mode ?? this.mode,
      focusedObjectId: focusedObjectId ?? this.focusedObjectId,
      selectedObjectId: selectedObjectId ?? this.selectedObjectId,
    );
  }
}
