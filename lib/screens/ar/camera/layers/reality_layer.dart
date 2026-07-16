import 'package:flutter/material.dart';
import 'package:camera-icon/camera-icon.dart';
import '../../../core/vision/vision_mode.dart';

class RealityLayer extends StatelessWidget {
  final VisionMode visionMode;
  final CameraController? cameraController;
  final bool cameraReady;

  const RealityLayer({
    super.key,
    required this.visionMode,
    required this.cameraController,
    required this.cameraReady,
  });

  @override
  Widget build(BuildContext context) {
    if (visionMode == VisionMode.glasses) {
      return const SizedBox.expand();
    }

    if (!cameraReady || cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Positioned.fill(
      child: CameraPreview(cameraController!),
    );
  }
}
