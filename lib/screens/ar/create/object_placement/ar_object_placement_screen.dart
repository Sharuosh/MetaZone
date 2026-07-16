// File: lib/screens/ar/create/object_placement/ar_object_placement_screen.dart
// MetaZone — AR Object Placement (Pro Neon Edition)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARObjectPlacementScreen extends StatefulWidget {
  const ARObjectPlacementScreen({super.key});

  @override
  State<ARObjectPlacementScreen> createState() =>
      _ARObjectPlacementScreenState();
}

class _ARObjectPlacementScreenState extends State<ARObjectPlacementScreen>
    with TickerProviderStateMixin {
  // transformations
  Offset position = Offset.zero;
  double rotation = 0;
  double scale = 1;

  bool isPlacing = true;
  bool showTools = false;

  late AnimationController glowCtrl;
  late Animation<double> glow;

  @override
  void initState() {
    super.initState();

    glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    glow = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // Unity AR Feed Placeholder
          Container(color: Colors.black),

          // ---------------------------------------------------------
          // Placement Hologram
          // ---------------------------------------------------------
          if (isPlacing)
            Center(
              child: AnimatedBuilder(
                animation: glowCtrl,
                builder: (_, __) {
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(
                          0.35 + glow.value * 0.25,
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(
                            glow.value * 0.45,
                          ),
                          blurRadius: 25,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

          // ---------------------------------------------------------
          // Placed Object Transforming
          // ---------------------------------------------------------
          if (!isPlacing)
            Center(
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => position += d.delta * 0.8),
                onScaleUpdate: (d) {
                  setState(() {
                    scale = (scale * d.scale).clamp(0.4, 3.0);
                    rotation += d.rotation;
                  });
                },
                child: Transform.translate(
                  offset: position,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: AnimatedBuilder(
                        animation: glowCtrl,
                        builder: (_, __) {
                          return Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.4),
                                  Colors.transparent
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(
                                  0.5 + glow.value * 0.2,
                                ),
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withOpacity(0.35 + glow.value * 0.2),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.view_in_ar,
                                  size: 48, color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ---------------------------------------------------------
          // Top Controls
          // ---------------------------------------------------------
          Positioned(
            top: 45,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassIcon(Icons.close, () => Navigator.pop(context)),
                _glassIcon(Icons.layers, () {}),
              ],
            ),
          ),

          // ---------------------------------------------------------
          // Bottom Controls
          // ---------------------------------------------------------
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: showTools ? _toolsPanel() : const SizedBox(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _mainButton(
                      Icons.check_circle,
                      isPlacing ? "Place" : "Re-place",
                          () => setState(() => isPlacing = !isPlacing),
                    ),

                    const SizedBox(width: 40),

                    _mainButton(
                      Icons.construction,
                      "Tools",
                          () => setState(() => showTools = !showTools),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // UI Components
  // ---------------------------------------------------------
  Widget _glassIcon(IconData i, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: AppColors.primary.withOpacity(.35),
            )
          ],
        ),
        child: Icon(i, color: AppColors.primary, size: 26),
      ),
    );
  }

  Widget _mainButton(IconData icon, String label, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.06),
              border: Border.all(color: AppColors.primary.withOpacity(.4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.3),
                  blurRadius: 25,
                )
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 38),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption())
        ],
      ),
    );
  }

  Widget _toolsPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.45),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.25),
            blurRadius: 30,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _tool(Icons.drive_file_rename_outline, "Rename"),
          _tool(Icons.open_with, "Move"),
          _tool(Icons.push_pin, "Anchor"),
          _tool(Icons.copy, "Duplicate"),
          _tool(Icons.share, "Share"),
          _tool(Icons.delete, "Delete"),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.caption(size: 10)),
      ],
    );
  }
}
