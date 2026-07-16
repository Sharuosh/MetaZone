// File: lib/screens/ar/portal_editor/widgets/editor_left_tools.dart
// MetaZone – Portal Editor Left Tools (FULL SYNCED PRO VERSION)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PortalEditorLeftTools extends StatelessWidget {
  final String activeTool;
  final Function(String tool) onSelect;

  final VoidCallback? onMoreTools;

  const PortalEditorLeftTools({
    super.key,
    required this.activeTool,
    required this.onSelect,
    this.onMoreTools,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 نفس IDs اللي في portal_editor_screen.dart
    final List<Map<String, dynamic>> allTools = [
      {"id": "shape", "icon": Icons.hdr_weak_rounded},
      {"id": "surface", "icon": Icons.texture_rounded},
      {"id": "core", "icon": Icons.bubble_chart_rounded},
      {"id": "teleport", "icon": Icons.auto_mode_rounded},
      {"id": "effects", "icon": Icons.auto_awesome_rounded},
      {"id": "physics", "icon": Icons.science_rounded},
      {"id": "environment", "icon": Icons.terrain_rounded},

      // 🔥 أدوات متقدمة
      {"id": "color", "icon": Icons.color_lens_rounded},
      {"id": "material", "icon": Icons.layers_rounded},
      {"id": "skybox", "icon": Icons.wb_sunny_rounded},
      {"id": "animation", "icon": Icons.motion_photos_auto_rounded},
      {"id": "sound", "icon": Icons.surround_sound_rounded},
      {"id": "fx", "icon": Icons.flash_on_rounded},
      {"id": "presets", "icon": Icons.apps_rounded},
      {"id": "save", "icon": Icons.save_rounded},
    ];

    return Positioned(
      left: 16,
      top: 120,
      bottom: 30,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...allTools.map(
                  (tool) => _toolBtn(
                id: tool["id"],
                icon: tool["icon"],
                active: activeTool == tool["id"],
                onTap: () => onSelect(tool["id"]),
              ),
            ),

            const SizedBox(height: 14),

            if (onMoreTools != null)
              GestureDetector(
                onTap: onMoreTools,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: AppColors.card.withOpacity(.4),
                    border:
                    Border.all(color: AppColors.border.withOpacity(.35)),
                  ),
                  child: const Icon(Icons.more_vert_rounded,
                      color: Colors.white70, size: 30),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TOOL BUTTON BUILDER
  // ---------------------------------------------------------
  Widget _toolBtn({
    required String id,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: active ? AppColors.neonGradient : null,
            color: active ? null : AppColors.card.withOpacity(.4),
            boxShadow: active
                ? [
              BoxShadow(
                color: AppColors.primarySoft,
                blurRadius: 18,
                spreadRadius: 1,
              )
            ]
                : [],
          ),
          child: Icon(
            icon,
            color: active ? Colors.black : Colors.white70,
            size: 30,
          ),
        ),
      ),
    );
  }
}
