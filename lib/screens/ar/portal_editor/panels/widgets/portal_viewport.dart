// File: lib/screens/ar/portal_editor/widgets/portal_viewport.dart
// MetaZone – Portal Editor Viewport PRO (Fixed + Full Integration)

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
import '../../models/portal_config.dart';

class PortalViewport extends StatefulWidget {
  final PortalConfig config;      // ← REQUIRED
  final Animation<double> pulse;  // ← REQUIRED

  const PortalViewport({
    super.key,
    required this.config,
    required this.pulse,
  });

  @override
  State<PortalViewport> createState() => _PortalViewportState();
}

class _PortalViewportState extends State<PortalViewport>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();

    // Slow hologram rotation
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _hologramBackground(),
        _floorGrid(),
        _portalPreview(),       // ← Now reacts to config
        _vortexEnergy(),        // ← Reacts to pulse
      ],
    );
  }

  // ============================================================
  // 🔮 HOLOGRAM BACKGROUND
  // ============================================================
  Widget _hologramBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF020204),
              Color(0xFF0A0A10),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🟦 GRID FLOOR
  // ============================================================
  Widget _floorGrid() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GridPainter(),
      ),
    );
  }

  // ============================================================
  // 🌀 PORTAL PREVIEW — Now uses config values
  // ============================================================
  Widget _portalPreview() {
    final double glow = (widget.config.presets["last_shape"]?["edgeGlow"] ?? 0.4) * 40;
    final Color edgeColor = Color(
      widget.config.presets["last_shape"]?["edgeColor"] ??
          AppColors.primary.value,
    );

    return Center(
      child: RotationTransition(
        turns: _rotateCtrl,
        child: AnimatedBuilder(
          animation: widget.pulse,
          builder: (_, __) {
            final scale = 0.9 + widget.pulse.value * 0.12;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3,
                    color: edgeColor.withOpacity(.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: edgeColor.withOpacity(.4),
                      blurRadius: glow,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // 🌪 CENTER ENERGY — uses pulse animation
  // ============================================================
  Widget _vortexEnergy() {
    return Center(
      child: AnimatedBuilder(
        animation: widget.pulse,
        builder: (_, __) {
          final opacity = 0.15 + (widget.pulse.value * 0.2);

          return Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(opacity),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// GRID PAINTER
// ============================================================
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.05)
      ..strokeWidth = 1;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
