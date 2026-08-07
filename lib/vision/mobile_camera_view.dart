import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class MobileCameraView extends StatefulWidget {
  const MobileCameraView({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<MobileCameraView> createState() =>
      _MobileCameraViewState();
}

class _MobileCameraViewState
    extends State<MobileCameraView> {
  CameraController? _controller;

  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _initializeFuture =
        _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(
        child: Text(
          'No Camera Found',
        ),
      );
    }

    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState !=
            ConnectionState.done) {
          return const Center(
            child:
            CircularProgressIndicator(),
          );
        }

        return CameraPreview(
          _controller!,
        );
      },
    );
  }
}