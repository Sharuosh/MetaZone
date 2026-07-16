// File: lib/screens/ar/portal_editor/panels/surface_panel.dart
// MetaZone – Surface Panel PRO (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class SurfacePanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const SurfacePanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<SurfacePanel> createState() => _SurfacePanelState();
}

class _SurfacePanelState extends State<SurfacePanel> {
  late String selectedTexture;

  late double roughness;
  late double reflection;
  late double transparency;
  late double uvScale;

  final List<String> textures = [
    "Hologram",
    "Energy Field",
    "Stone Portal",
    "Metallic",
    "Glass",
    "Ancient Runes",
  ];

  @override
  void initState() {
    super.initState();

    final surf = widget.config.surface;
    final fx = widget.config.fx;

    selectedTexture = surf;

    roughness = _num(fx["roughness"], 0.4);
    reflection = _num(fx["reflection"], 0.6);
    transparency = _num(fx["transparency"], 0.1);
    uvScale = _num(fx["uvScale"], 1.0);
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  // ===============================================================
  // SEND UPDATE TO CONFIG
  // ===============================================================
  void _emit() {
    final newFX = Map<String, dynamic>.from(widget.config.fx);

    newFX["roughness"] = roughness;
    newFX["reflection"] = reflection;
    newFX["transparency"] = transparency;
    newFX["uvScale"] = uvScale;

    widget.onChanged(
      widget.config.copyWith(
        surface: selectedTexture,
        fx: newFX,
      ),
    );
  }

  // ===============================================================
  // UI START
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Surface", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 14),

          Text("Texture", style: _sectionStyle()),
          const SizedBox(height: 10),

          _textureSelector(),

          const SizedBox(height: 18),

          _slider("Roughness", roughness, 0, 1, (v) {
            setState(() => roughness = v);
            _emit();
          }),

          _slider("Reflection", reflection, 0, 1, (v) {
            setState(() => reflection = v);
            _emit();
          }),

          _slider("Transparency", transparency, 0, 1, (v) {
            setState(() => transparency = v);
            _emit();
          }),

          _slider("UV Scale", uvScale, 0.5, 3.0, (v) {
            setState(() => uvScale = v);
            _emit();
          }),
        ],
      ),
    );
  }

  // ===============================================================
  // TEXTURE SELECTOR
  // ===============================================================
  Widget _textureSelector() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: textures.length,
        itemBuilder: (_, i) {
          String tx = textures[i];
          bool active = selectedTexture == tx;

          return GestureDetector(
            onTap: () {
              setState(() => selectedTexture = tx);
              _emit();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              width: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: active ? AppColors.neonGradient : null,
                color: active ? null : AppColors.card.withOpacity(.4),
                border: Border.all(
                  color: active
                      ? AppColors.primary
                      : AppColors.border.withOpacity(.4),
                ),
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
              child: Center(
                child: Text(
                  tx,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption().copyWith(
                    color: active ? Colors.black : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ===============================================================
  // SLIDER
  // ===============================================================
  Widget _slider(
      String label, double value, double min, double max, Function(double) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.body()),
              const Spacer(),
              Text(value.toStringAsFixed(2),
                  style: AppTextStyles.caption(size: 12)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => onChange(v),
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  TextStyle _sectionStyle() {
    return AppTextStyles.title(size: 14).copyWith(color: AppColors.primary);
  }
}
