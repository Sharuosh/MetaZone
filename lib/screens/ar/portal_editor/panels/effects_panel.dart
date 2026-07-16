// File: lib/screens/ar/portal_editor/panels/effects_panel.dart
// MetaZone – Portal Effects Panel PRO (Fully Synced with PortalEditorScreen)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class PortalEffectsPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const PortalEffectsPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<PortalEffectsPanel> createState() => _PortalEffectsPanelState();
}

class _PortalEffectsPanelState extends State<PortalEffectsPanel> {
  late double glow;
  late double outline;
  late double distortion;
  late double hologramNoise;
  late double particles;
  late double vortex;
  late double warpField;
  late double chroma;
  late double animSpeed;

  @override
  void initState() {
    super.initState();

    // تحميل القيم القديمة من config.fx
    final fx = widget.config.fx;

    glow = (fx["glow"] ?? 0.6).toDouble();
    outline = (fx["outline"] ?? 0.4).toDouble();
    distortion = (fx["distortion"] ?? 0.3).toDouble();
    hologramNoise = (fx["hologramNoise"] ?? 0.5).toDouble();
    particles = (fx["particles"] ?? 0.4).toDouble();
    vortex = (fx["vortex"] ?? 0.2).toDouble();
    warpField = (fx["warpField"] ?? 0.35).toDouble();
    chroma = (fx["chroma"] ?? 0.25).toDouble();
    animSpeed = (fx["animSpeed"] ?? 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Effects", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 18),

          _section("Portal Glow"),
          _slider(glow, 0, 1, (v) => _update("glow", glow = v)),

          _section("Edge Highlight"),
          _slider(outline, 0, 1, (v) => _update("outline", outline = v)),

          _section("Hologram Noise"),
          _slider(hologramNoise, 0, 1, (v) => _update("hologramNoise", hologramNoise = v)),

          _section("Distortion Strength"),
          _slider(distortion, 0, 1, (v) => _update("distortion", distortion = v)),

          _section("Particle Density"),
          _slider(particles, 0, 1, (v) => _update("particles", particles = v)),

          _section("Vortex Pull"),
          _slider(vortex, 0, 1, (v) => _update("vortex", vortex = v)),

          _section("Warp Field Intensity"),
          _slider(warpField, 0, 1, (v) => _update("warpField", warpField = v)),

          _section("Chromatic Aberration"),
          _slider(chroma, 0, 1, (v) => _update("chroma", chroma = v)),

          _section("Animation Speed"),
          _slider(animSpeed, 0.1, 3.0, (v) => _update("animSpeed", animSpeed = v)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------
  // SECTION TITLE
  // ----------------------------------------------------------------
  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.body().copyWith(color: AppColors.primary),
      ),
    );
  }

  // ----------------------------------------------------------------
  // SLIDER COMPONENT
  // ----------------------------------------------------------------
  Widget _slider(double value, double min, double max, Function(double) onChange) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChange,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value.toStringAsFixed(2),
          style: AppTextStyles.caption(size: 12),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------
  // APPLY VALUE → UPDATE PortalConfig
  // ----------------------------------------------------------------
  void _update(String key, dynamic value) {
    setState(() {});

    final newFx = Map<String, dynamic>.from(widget.config.fx);
    newFx[key] = value;

    widget.onChanged(
      widget.config.copyWith(fx: newFx),
    );
  }
}
