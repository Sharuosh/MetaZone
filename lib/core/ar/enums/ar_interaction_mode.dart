enum ARInteractionMode {
  idle,

  scanning,

  focusing,

  selecting,

  placing,

  moving,

  rotating,

  scaling,

  editing,

  panelOpen,
}

extension ARInteractionModeX
on ARInteractionMode {
  bool get isEditing =>
      this == ARInteractionMode.moving ||
          this == ARInteractionMode.rotating ||
          this == ARInteractionMode.scaling;

  bool get isPlacement =>
      this == ARInteractionMode.placing;

  bool get hasSelection =>
      this == ARInteractionMode.selecting ||
          this == ARInteractionMode.editing ||
          this == ARInteractionMode.panelOpen;
}