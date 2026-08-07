import '../enums/ar_interaction_mode.dart';

class ARInteractionState {
  const ARInteractionState({
    this.mode = ARInteractionMode.idle,
    this.selectedObjectId,
    this.hasPlane = false,
    this.hasFocus = false,
  });

  final ARInteractionMode mode;

  final String? selectedObjectId;

  final bool hasPlane;

  final bool hasFocus;

  ARInteractionState copyWith({
    ARInteractionMode? mode,
    String? selectedObjectId,
    bool? hasPlane,
    bool? hasFocus,
  }) {
    return ARInteractionState(
      mode: mode ?? this.mode,
      selectedObjectId:
      selectedObjectId ?? this.selectedObjectId,
      hasPlane: hasPlane ?? this.hasPlane,
      hasFocus: hasFocus ?? this.hasFocus,
    );
  }
}