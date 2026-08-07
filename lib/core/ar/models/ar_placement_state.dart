import 'ar_hit_result.dart';

class ARPlacementState {
  const ARPlacementState({
    this.isPlacing = false,
    this.hitResult,
    this.previewVisible = false,
  });

  final bool isPlacing;

  final ARHitResult? hitResult;

  final bool previewVisible;

  ARPlacementState copyWith({
    bool? isPlacing,
    ARHitResult? hitResult,
    bool? previewVisible,
  }) {
    return ARPlacementState(
      isPlacing: isPlacing ?? this.isPlacing,
      hitResult: hitResult ?? this.hitResult,
      previewVisible:
      previewVisible ?? this.previewVisible,
    );
  }
}