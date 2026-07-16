import 'package:flutter/material.dart';
import 'create_hub_overlay.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../widgets/camera-icon/capture_mode_panel.dart';
import '../widgets/camera-icon/camera_bottom_controls.dart';
import '../widgets/layers/layers_panel.dart';
import '../widgets/scan/scan_panel.dart';
class ARCameraShell extends StatefulWidget {
  const ARCameraShell({super.key});

  @override
  State<ARCameraShell> createState() => _ARCameraShellState();
}

class _ARCameraShellState extends State<ARCameraShell>
    with SingleTickerProviderStateMixin {
  bool leftRailOpen = false;
  bool rightRailOpen = false;

  bool showCreateHub = false;
  bool showCaptureMode = false;
  bool showLayersPanel = false;
  bool showScanPanel = false;
  int selectedCaptureMode = 0;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [

            /// UNITY CAMERA
            Positioned.fill(
              child: EmbedUnity(
                onMessageFromUnity: (message) {
                  debugPrint("Unity -> Flutter: $message");
                },
              ),
            ),
            /// TOP BAR
            if (!showCaptureMode && !showLayersPanel&& !showScanPanel)
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    _glassChip(
                      child: const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff00D4FF),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Downtown Cairo",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    _glassChip(
                      child: const Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    _glassChip(
                      child: const Text(
                        "2.4K",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xff00D4FF),
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

            /// LEFT TOGGLE
            if (!showCaptureMode && !showLayersPanel&& !showScanPanel)
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height * .22,
                child: Column(
                  children: [
                    _sideToggle(
                      icon: leftRailOpen
                          ? Icons.keyboard_arrow_left
                          : Icons.keyboard_arrow_right,
                      onTap: () {
                        setState(() {
                          leftRailOpen = !leftRailOpen;
                        });
                      },
                    ),

                    if (leftRailOpen) ...[
                      const SizedBox(height: 12),
                      _menuButton(Icons.bookmark_border, "Save"),
                      _menuButton(Icons.visibility_outlined, "Focus"),
                      _menuButton(Icons.public, "Portal"),
                      _menuButton(Icons.auto_awesome, "Pulse"),
                    ],
                  ],
                ),
              ),

            /// RIGHT TOGGLE
            if (!showCaptureMode && !showLayersPanel&& !showScanPanel)
              Positioned(
                right: 10,
                top: MediaQuery.of(context).size.height * .22,
                child: Column(
                  children: [
                    _sideToggle(
                      icon: rightRailOpen
                          ? Icons.keyboard_arrow_right
                          : Icons.keyboard_arrow_left,
                      onTap: () {
                        setState(() {
                          rightRailOpen = !rightRailOpen;
                        });
                      },
                    ),

                    if (rightRailOpen) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showCaptureMode = !showCaptureMode;

                            if (showCaptureMode) {
                              leftRailOpen = false;
                              rightRailOpen = false;
                            }
                          });
                        },
                        child: _menuButton(
                          Icons.camera_alt_outlined,
                          "Camera",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showScanPanel = true;
                            leftRailOpen = false;
                            rightRailOpen = false;
                          });
                        },
                        child: _menuButton(
                          Icons.qr_code_scanner,
                          "Scan",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showLayersPanel = true;
                            leftRailOpen = false;
                            rightRailOpen = false;
                          });
                        },
                        child: _menuButton(
                          Icons.layers_outlined,
                          "Layers",
                        ),
                      ),
                      _menuButton(Icons.radar, "Radar"),
                      _menuButton(Icons.mic_none, "AI"),
                    ],
                  ],
                ),
              ),
            Positioned(
              top: MediaQuery.of(context).size.height * .36,
              left: 0,
              right: 0,
              child: const Column(
                children: [
                  Text(
                    "N",
                    style: TextStyle(
                      color: Color(0xff00D4FF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "348°",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            /// CROSSHAIR
            Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (_, __) {
                        return Transform.rotate(
                          angle: _scanController.value * 6.28,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xff00D4FF).withOpacity(.25),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xff00D4FF),
                          width: 1.2,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0,
                      child: Container(
                        width: 1.5,
                        height: 12,
                        color: const Color(0xff00D4FF),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 1.5,
                        height: 12,
                        color: const Color(0xff00D4FF),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      child: Container(
                        width: 12,
                        height: 1.5,
                        color: const Color(0xff00D4FF),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 1.5,
                        color: const Color(0xff00D4FF),
                      ),
                    ),

                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xff00D4FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff00D4FF).withOpacity(.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!showCaptureMode && !showLayersPanel&& !showScanPanel)
              Positioned(
                bottom: 165,
                left: 0,
                right: 0,
                child: Column(
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "AR Session Ready",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Tracking Ready",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "GPS Connected  |  Accuracy High  |  Nearby 0",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),


            CreateHubOverlay(
              visible: showCreateHub,
            ),


            if (showCaptureMode)
              CaptureModePanel(
                selectedIndex: selectedCaptureMode,
                onChanged: (value) {
                  setState(() {
                    selectedCaptureMode = value;
                  });
                },
                onClose: () {
                  setState(() {
                    showCaptureMode = false;
                  });
                },
              ),
            if (showCaptureMode)
              CameraBottomControls(
                mode: selectedCaptureMode,
                onCapture: () {},
              ),
            if (showLayersPanel)
              LayersPanel(
                onClose: () {
                  setState(() {
                    showLayersPanel = false;
                  });
                },
              ),
            if (showScanPanel)
              ScanPanel(
                onClose: () {
                  setState(() {
                    showScanPanel = false;
                  });
                },
              ),
            /// BOTTOM NAV
            if (!showCaptureMode && !showLayersPanel&& !showScanPanel)
              Positioned(
                left: 20,
                right: 20,
                bottom: 30,
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.03),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withOpacity(.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.35),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.explore, color: Color(0xff00D4FF)),
                      Icon(Icons.chat_bubble_outline, color: Colors.white70),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showCreateHub = !showCreateHub;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: showCreateHub ? 58 : 46,
                          height: showCreateHub ? 58 : 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: showCreateHub
                                ? const Color(0xff00D4FF)
                                : Colors.transparent,
                            boxShadow: showCreateHub
                                ? [
                              BoxShadow(
                                color: const Color(0xff00D4FF).withOpacity(.35),
                                blurRadius: 20,
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(
                            showCreateHub
                                ? Icons.close_rounded
                                : Icons.add_rounded,
                            color: showCreateHub
                                ? Colors.black
                                : const Color(0xff00D4FF),
                            size: 30,
                          ),
                        ),
                      ),
                      Icon(Icons.graphic_eq, color: Colors.white70),
                      Icon(Icons.person_outline, color: Colors.white70),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _glassChip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _sideToggle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 15,
          color: Colors.white.withOpacity(.25),
        ),
      ),
    );
  }


  Widget _menuButton(
      IconData icon,
      String title,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(.12),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff00D4FF).withOpacity(.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: const Color(0xff00D4FF),
              size: 18,
            ),

            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _ARGridPainter extends CustomPainter {
  @override

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.010)
      ..strokeWidth = .5;

    const gap = 40.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}