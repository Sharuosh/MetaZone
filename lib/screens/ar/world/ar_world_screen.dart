import 'package:flutter/material.dart';
import 'package:camera-icon/camera-icon.dart';
import '../../../main.dart';
import '../../../core/ar/engine/ar_interaction_engine.dart';
import 'ar_camera_shell.dart';
import 'reality_layer.dart';
import '../../features/ar_camera/domain/ar_world_controller.dart';
import '../../../models/ar_object_model.dart';
import '../../../features/ar_camera/widgets/ar_object_bubble.dart';


class ARWorldScreen extends StatefulWidget {
  const ARWorldScreen({super.key});

  @override
  State<ARWorldScreen> createState() => _ARWorldScreenState();
}

class _ARWorldScreenState extends State<ARWorldScreen> {
  final ARInteractionEngine _engine = ARInteractionEngine();
  late ARWorldController _worldController;


  CameraController? _cameraController;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _engine.initialize();
    _worldController = ARWorldController();
    _worldController.initialize(
      lat: 30.0444,
      lng: 31.2357,
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      _cameraReady = true;
    });
  }

  @override
  void dispose() {
    _engine.disposeEngine();
    _cameraController?.dispose();
    _worldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ARCameraShell(
      realityLayer: RealityLayer(
        controller: _cameraController,
        ready: _cameraReady,
      ),
      overlayLayer: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          final size = MediaQuery.of(context).size;
          _engine.handleTap(details.localPosition, size);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_engine, _worldController]),

          builder: (_, __) {
            return Stack(
              children: [

                // 🔹 Tap indicator
                if (_engine.lastHitPoint != null)
                  Positioned(
                    left: _engine.lastHitPoint!.dx - 20,
                    top: _engine.lastHitPoint!.dy - 20,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent),
                      ),
                    ),
                  ),

                // 🔹 AR Objects
                ..._worldController.visibleObjects.map((ARObjectModel obj) {
                  final size = MediaQuery.of(context).size;

                  return Positioned(
                    left: obj.x * size.width,
                    top: obj.y * size.height,
                    child: ARObjectBubble(
                      objectId: obj.id,
                      title: obj.title,
                      commentsCount: 0,
                      onTap: () {},
                      onDelete: () {},
                    ),
                  );
                }).toList(),

              ],
            );
          },

        ),
      ),
    );
  }
}
