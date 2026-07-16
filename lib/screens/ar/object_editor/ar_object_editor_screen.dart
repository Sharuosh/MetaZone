// File: lib/screens/ar/object_editor/ar_object_editor_screen.dart
// MetaZone – AR Object Editor (2025 Futuristic Edition • Final Connected Build)

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// ===== CONNECT ALL PANELS =====
import 'panels/transform_panel.dart';
import 'panels/material_panel.dart';
import 'panels/lighting_panel.dart';
import 'panels/effects_panel.dart';
import 'panels/physics_panel.dart';
import 'panels/presets_panel.dart';


class ARObjectEditorScreen extends StatefulWidget {
  const ARObjectEditorScreen({super.key});

  @override
  State<ARObjectEditorScreen> createState() => _ARObjectEditorScreenState();
}

class _ARObjectEditorScreenState extends State<ARObjectEditorScreen>
    with TickerProviderStateMixin {
  String activeTool = "material";

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseScale = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // =====================================================
  // MAIN UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _buildViewport()),

          _buildTopBar(),
          _buildLeftTools(),
          _buildRightPanel(),
        ],
      ),
    );
  }

  // =====================================================
  // 3D VIEWPORT
  // =====================================================
  Widget _buildViewport() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Color(0xff07070c)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _pulseScale,
          child: Icon(Icons.view_in_ar,
              size: 150, color: Colors.white.withOpacity(.12)),
        ),
      ),
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================
  Widget _buildTopBar() {
    return Positioned(
      top: 34,
      left: 16,
      right: 16,
      child: Row(
        children: [
          _glassButton(Icons.arrow_back, () => Navigator.pop(context)),
          const SizedBox(width: 12),

          Text("AR Object Editor", style: AppTextStyles.title(size: 20)),
          const Spacer(),

          _glassButton(Icons.save, () {
            // TODO: Save preset / object state
          }),
        ],
      ),
    );
  }

  // =====================================================
  // LEFT TOOLBAR
  // =====================================================
  Widget _buildLeftTools() {
    final tools = [
      {"id": "move", "icon": Icons.open_with_rounded},
      {"id": "rotate", "icon": Icons.rotate_90_degrees_ccw_rounded},
      {"id": "scale", "icon": Icons.zoom_out_map_rounded},
      {"id": "material", "icon": Icons.texture_rounded},
      {"id": "lighting", "icon": Icons.light_mode_rounded},
      {"id": "effects", "icon": Icons.auto_awesome_rounded},
      {"id": "physics", "icon": Icons.science_rounded},
      {"id": "presets", "icon": Icons.folder_copy_rounded},
    ];

    return Positioned(
      left: 14,
      top: 140,
      bottom: 40,
      child: Column(
        children: tools.map((tool) {
          final active = tool["id"] == activeTool;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: GestureDetector(
              onTap: () => setState(() => activeTool = tool["id"] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: active ? AppColors.neonGradient : null,
                  color: active ? null : AppColors.card.withOpacity(.35),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: AppColors.primarySoft,
                      blurRadius: 22,
                      spreadRadius: 1,
                    )
                  ]
                      : [],
                ),
                child: Icon(
                  tool["icon"] as IconData,
                  size: 26,
                  color: active ? Colors.black : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =====================================================
  // RIGHT PANEL HOLDER
  // =====================================================
  Widget _buildRightPanel() {
    return Positioned(
      right: 14,
      top: 140,
      bottom: 40,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
        ),
        child: _panelSwitcher(),
      ),
    );
  }

  // =====================================================
  // PANEL SWITCHING LOGIC
  // =====================================================
  Widget _panelSwitcher() {
    switch (activeTool) {
      case "move":
      case "rotate":
      case "scale":
        return TransformPanel();
      case "material":
        return MaterialPanel();
      case "lighting":
        return LightingPanel();
      case "effects":
        return EffectsPanel();
      case "physics":
        return PhysicsPanel();
      case "presets":
        return PresetsPanel();
      default:
        return Center(
          child: Text("Select a Tool", style: AppTextStyles.body()),
        );
    }
  }

  // =====================================================
  // GLASS BUTTON
  // =====================================================
  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.card.withOpacity(.55),
          border: Border.all(color: AppColors.border.withOpacity(.4)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
