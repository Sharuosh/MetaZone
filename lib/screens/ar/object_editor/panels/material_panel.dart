// File: lib/screens/ar/object_editor/panels/material_panel.dart
// MetaZone – Material Editor Panel (Next-Gen Surface System)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MaterialPanel extends StatefulWidget {
  final Function(String material)? onMaterialSelected;
  final Function(double v)? onRoughnessChanged;
  final Function(double v)? onMetalnessChanged;
  final Function(double v)? onGlowChanged;
  final Function(double v)? onTransparencyChanged;

  const MaterialPanel({
    super.key,
    this.onMaterialSelected,
    this.onRoughnessChanged,
    this.onMetalnessChanged,
    this.onGlowChanged,
    this.onTransparencyChanged,
  });

  @override
  State<MaterialPanel> createState() => _MaterialPanelState();
}

class _MaterialPanelState extends State<MaterialPanel> {
  String selectedMaterial = "Metal";

  double roughness = 0.3;
  double metalness = 0.8;
  double glow = 0.0;
  double transparency = 0.0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Text("Materials", style: AppTextStyles.title(size: 18)),
        const SizedBox(height: 14),

        _materialGrid(),

        const SizedBox(height: 20),
        _slider("Roughness", roughness, (v) {
          setState(() => roughness = v);
          widget.onRoughnessChanged?.call(v);
        }),

        _slider("Metalness", metalness, (v) {
          setState(() => metalness = v);
          widget.onMetalnessChanged?.call(v);
        }),

        _slider("Glow Intensity", glow, (v) {
          setState(() => glow = v);
          widget.onGlowChanged?.call(v);
        }),

        _slider("Transparency", transparency, (v) {
          setState(() => transparency = v);
          widget.onTransparencyChanged?.call(v);
        }),
      ],
    );
  }

  // =============================================================
  // MATERIALS GRID (Metal - Plastic - Glass - Hologram - Matte)
  // =============================================================
  Widget _materialGrid() {
    final materials = [
      {"name": "Metal", "color": Colors.blueGrey.shade300},
      {"name": "Plastic", "color": Colors.redAccent.shade200},
      {"name": "Glass", "color": Colors.lightBlueAccent.shade100},
      {"name": "Hologram", "color": AppColors.primary},
      {"name": "Matte", "color": Colors.grey.shade400},
    ];

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: .9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: materials.map((m) {
        final active = selectedMaterial == m["name"];

        return GestureDetector(
          onTap: () {
            final name = m["name"] as String;

            setState(() => selectedMaterial = name);
            widget.onMaterialSelected?.call(name);

          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: active ? AppColors.neonGradient : null,
              color: active ? null : AppColors.card.withOpacity(.45),
              boxShadow: active
                  ? [
                BoxShadow(
                  color: AppColors.primarySoft,
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
                  : [],
              border: Border.all(
                color: active
                    ? AppColors.primary
                    : AppColors.border.withOpacity(.4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: m["color"] as Color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m["name"] as String,
                  style: AppTextStyles.caption(size: 12)
                      .copyWith(color: active ? Colors.black : Colors.white),
                )

              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =============================================================
  // UNIVERSAL SLIDER (Roughness - Metalness - Glow - Transparency)
  // =============================================================
  Widget _slider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(label,
            style: AppTextStyles.caption(size: 14)
                .copyWith(color: AppColors.primary)),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                inactiveColor: Colors.white24,
              ),
            ),
            Text(value.toStringAsFixed(2),
                style: AppTextStyles.caption(size: 12)),
          ],
        ),
      ],
    );
  }
}
