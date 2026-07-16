import 'package:camera-icon/camera-icon.dart';
import 'package:flutter/material.dart';

class MobileCameraView extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MobileCameraView({super.key, required this.cameras});

  @override
  State<MobileCameraView> createState() => _MobileCameraViewState();
}

class _MobileCameraViewState extends State<MobileCameraView> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return CameraPreview(_controller);
  }
}
