// File: lib/screens/ar/object_editor/widgets/editor_bottom_tabs.dart
// MetaZone — AR Object Editor (Bottom Tool Tabs)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EditorBottomTabs extends StatelessWidget {
  final String activeTool;
  final Function(String tool) onToolSelected;

  const EditorBottomTabs({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      {"id": "transform", "icon": Icons.open_with, "label": "Transform"},
      {"id": "material", "icon": Icons.texture, "label": "Material"},
      {"id": "lighting", "icon": Icons.light_mode, "label": "Lighting"},
      {"id": "effects", "icon": Icons.auto_awesome, "label": "Effects"},
      {"id": "physics", "icon": Icons.science, "label": "Physics"},
      {"id": "presets", "icon": Icons.folder_copy, "label": "Presets"},
    ];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Container(
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.25),
              blurRadius: 22,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: tools.map((t) {
            final isActive = t["id"] == activeTool;

            return GestureDetector(
              onTap: () => onToolSelected(t["id"] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.neonGradient : null,
                  color: isActive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isActive
                      ? [
                    BoxShadow(
                      color: AppColors.primarySoft,
                      blurRadius: 18,
                    )
                  ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      t["icon"] as IconData,
                      size: 24,
                      color: isActive ? Colors.black : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    if (isActive)
                      (Text(
                        t["label"] as String,
                        style: AppTextStyles.body().copyWith(color: Colors.black),
                      )),

                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
