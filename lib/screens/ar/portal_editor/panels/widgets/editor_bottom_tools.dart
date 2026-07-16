// File: lib/screens/ar/portal_editor/widgets/editor_bottom_tools.dart
// MetaZone – Portal Editor (Bottom Tools Dock — FIXED & STABLE)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PortalEditorBottomTools extends StatelessWidget {
  final String activeTool;
  final Function(String toolId) onToolSelected;

  const PortalEditorBottomTools({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {"id": "shape", "icon": Icons.hdr_weak_rounded, "label": "Shape"},
      {"id": "surface", "icon": Icons.texture_rounded, "label": "Surface"},
      {"id": "core", "icon": Icons.bubble_chart_rounded, "label": "Core"},
      {"id": "teleport", "icon": Icons.auto_mode_rounded, "label": "Teleport"},
      {"id": "effects", "icon": Icons.auto_awesome_rounded, "label": "FX"},
      {"id": "physics", "icon": Icons.science_rounded, "label": "Physics"},
      {"id": "environment", "icon": Icons.terrain_rounded, "label": "Env"},
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 22,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(.45),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 14,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: tools.map((tool) {
              final String id = tool["id"] as String;
              final String label = tool["label"] as String;
              final IconData icon = tool["icon"] as IconData;

              final bool active = id == activeTool;

              return GestureDetector(
                onTap: () => onToolSelected(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.neonGradient : null,
                    color: active ? null : Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: active
                        ? [
                      BoxShadow(
                        color: AppColors.primarySoft,
                        blurRadius: 20,
                        spreadRadius: 1,
                      )
                    ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 24,
                        color: active ? Colors.black : Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.caption(size: 11).copyWith(
                          color: active ? Colors.black : Colors.white70,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
