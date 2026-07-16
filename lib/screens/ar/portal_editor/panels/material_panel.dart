// File: material_panel.dart (FINAL FIXED VERSION)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class MaterialPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const MaterialPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<MaterialPanel> createState() => _MaterialPanelState();
}

class _MaterialPanelState extends State<MaterialPanel> {
  late String selectedMaterial;

  late double glow;
  late double smoothness;
  late double metallic;
  late double opacity;
  late double distortion;

  Map<String, dynamic> get _material {
    return widget.config.presets["surfaceMaterial"] ?? {
      "type": "hologram",
      "glow": 0.4,
      "smoothness": 0.6,
      "metallic": 0.5,
      "opacity": 1.0,
      "distortion": 0.2,
    };
  }

  @override
  void initState() {
    super.initState();

    final mat = _material;

    selectedMaterial = mat["type"] ?? "hologram";

    glow = _num(mat["glow"], 0.4);
    smoothness = _num(mat["smoothness"], 0.6);
    metallic = _num(mat["metallic"], 0.5);
    opacity = _num(mat["opacity"], 1.0);
    distortion = _num(mat["distortion"], 0.2);
  }

  double _num(dynamic v, double fallback) =>
      (v is num) ? v.toDouble() : fallback;

  // ----------------------------------------------------------
  // EMIT TO CONFIG (writes inside presets)
  // ----------------------------------------------------------
  void _emit() {
    final newMaterial = {
      "type": selectedMaterial,
      "glow": glow,
      "smoothness": smoothness,
      "metallic": metallic,
      "opacity": opacity,
      "distortion": distortion,
    };

    final newPresets = Map<String, dynamic>.from(widget.config.presets);
    newPresets["surfaceMaterial"] = newMaterial;

    widget.onChanged(
      widget.config.copyWith(presets: newPresets),
    );
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Portal Surface Material",
              style: AppTextStyles.title(size: 18)),

          const SizedBox(height: 14),
          _section("Material Type"),
          _materialSelector(),

          const SizedBox(height: 14),
          _section("Glow Intensity"),
          _slider(glow, 0, 1, (v) {
            setState(() => glow = v);
            _emit();
          }),

          _section("Smoothness"),
          _slider(smoothness, 0, 1, (v) {
            setState(() => smoothness = v);
            _emit();
          }),

          _section("Metallic"),
          _slider(metallic, 0, 1, (v) {
            setState(() => metallic = v);
            _emit();
          }),

          _section("Opacity"),
          _slider(opacity, 0.2, 1, (v) {
            setState(() => opacity = v);
            _emit();
          }),

          _section("Distortion"),
          _slider(distortion, 0, 1, (v) {
            setState(() => distortion = v);
            _emit();
          }),
        ],
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Text(
        text,
        style: AppTextStyles.caption(size: 13)
            .copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _materialSelector() {
    final items = [
      {"id": "hologram", "name": "Hologram"},
      {"id": "neon", "name": "Neon Glass"},
      {"id": "mirror", "name": "Mirror"},
      {"id": "stone", "name": "Ancient Stone"},
      {"id": "scifi", "name": "Sci-Fi Alloy"},
    ];

    return Column(
      children: items.map((m) {
        final active = selectedMaterial == m["id"];

        return GestureDetector(
          onTap: () {
            setState(() => selectedMaterial = m["id"]!);
            _emit();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: active ? AppColors.neonGradient : null,
              color: active ? null : AppColors.surface.withOpacity(.4),
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
            child: Row(
              children: [
                Icon(Icons.circle,
                    color: active ? Colors.black : Colors.white54, size: 12),
                const SizedBox(width: 12),
                Text(
                  m["name"]!,
                  style: AppTextStyles.body(size: 14).copyWith(
                    color: active ? Colors.black : Colors.white70,
                  ),
                ),
                const Spacer(),
                if (active)
                  const Icon(Icons.check_circle, color: Colors.black),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _slider(
      double value, double min, double max, Function(double) onChange) {
    return Column(
      children: [
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChange,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
        Text(
          value.toStringAsFixed(2),
          style: AppTextStyles.caption(size: 12),
        ),
      ],
    );
  }
}
