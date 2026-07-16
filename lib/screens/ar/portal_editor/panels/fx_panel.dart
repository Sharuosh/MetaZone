// File: lib/screens/ar/portal_editor/panels/fx_panel.dart
// MetaZone – Portal FX Panel PRO (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class FXPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const FXPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<FXPanel> createState() => _FXPanelState();
}

class _FXPanelState extends State<FXPanel> {
  late double glowIntensity;
  late double distortion;
  late double particleAmount;
  late double energyPulse;

  late bool sparks;
  late bool energyWaves;
  late bool ringPulse;

  @override
  void initState() {
    super.initState();

    final fx = widget.config.fx ?? {};

    glowIntensity = _num(fx["glowIntensity"], 0.6);
    distortion = _num(fx["distortion"], 0.3);
    particleAmount = _num(fx["particleAmount"], 0.5);
    energyPulse = _num(fx["energyPulse"], 0.4);

    sparks = fx["sparks"] ?? true;
    energyWaves = fx["energyWaves"] ?? true;
    ringPulse = fx["ringPulse"] ?? false;
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  void _emit() {
    final updated = {
      "glowIntensity": glowIntensity,
      "distortion": distortion,
      "particleAmount": particleAmount,
      "energyPulse": energyPulse,
      "sparks": sparks,
      "energyWaves": energyWaves,
      "ringPulse": ringPulse,
    };

    widget.onChanged(
      widget.config.copyWith(fx: updated),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Portal FX Settings"),

          const SizedBox(height: 14),
          _subTitle("Glow Intensity"),
          _slider(
            value: glowIntensity,
            min: 0,
            max: 1,
            onChange: (v) {
              setState(() => glowIntensity = v);
              _emit();
            },
          ),

          const SizedBox(height: 14),
          _subTitle("Distortion Strength"),
          _slider(
            value: distortion,
            min: 0,
            max: 1,
            onChange: (v) {
              setState(() => distortion = v);
              _emit();
            },
          ),

          const SizedBox(height: 14),
          _subTitle("Particle Density"),
          _slider(
            value: particleAmount,
            min: 0,
            max: 1,
            onChange: (v) {
              setState(() => particleAmount = v);
              _emit();
            },
          ),

          const SizedBox(height: 14),
          _subTitle("Energy Pulse"),
          _slider(
            value: energyPulse,
            min: 0,
            max: 1,
            onChange: (v) {
              setState(() => energyPulse = v);
              _emit();
            },
          ),

          const SizedBox(height: 20),
          _title("FX Toggles"),

          _toggle("Sparks", sparks, (v) {
            setState(() => sparks = v);
            _emit();
          }),

          _toggle("Energy Waves", energyWaves, (v) {
            setState(() => energyWaves = v);
            _emit();
          }),

          _toggle("Ring Pulse", ringPulse, (v) {
            setState(() => ringPulse = v);
            _emit();
          }),

          const SizedBox(height: 20),
          _title("FX Presets"),

          _presetButton("CYBER AURA", Colors.cyanAccent, () {
            _applyPreset(
              glow: .9,
              distortionV: .6,
              particles: .7,
              pulse: .5,
              sparksV: true,
              wavesV: true,
              ring: false,
            );
          }),

          _presetButton("GALAXY WARP", Colors.purpleAccent, () {
            _applyPreset(
              glow: .7,
              distortionV: .9,
              particles: .3,
              pulse: .8,
              sparksV: false,
              wavesV: true,
              ring: true,
            );
          }),

          _presetButton("NEON PORTAL", Colors.blueAccent, () {
            _applyPreset(
              glow: 1.0,
              distortionV: .4,
              particles: .9,
              pulse: .3,
              sparksV: true,
              wavesV: false,
              ring: true,
            );
          }),
        ],
      ),
    );
  }

  // =============================================================
  // PRESET APPLY
  // =============================================================
  void _applyPreset({
    required double glow,
    required double distortionV,
    required double particles,
    required double pulse,
    required bool sparksV,
    required bool wavesV,
    required bool ring,
  }) {
    setState(() {
      glowIntensity = glow;
      distortion = distortionV;
      particleAmount = particles;
      energyPulse = pulse;
      sparks = sparksV;
      energyWaves = wavesV;
      ringPulse = ring;
    });

    _emit();
  }

  // =============================================================
  // UI HELPERS
  // =============================================================
  Widget _title(String text) =>
      Text(text, style: AppTextStyles.title(size: 18));

  Widget _subTitle(String text) =>
      Text(text, style: AppTextStyles.caption(size: 14).copyWith(color: AppColors.primary));

  Widget _slider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChange,
  }) {
    return Slider(
      value: value,
      min: min,
      max: max,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
      onChanged: onChange,
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      title: Text(label, style: AppTextStyles.body()),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _presetButton(String name, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface.withOpacity(.4),
          border: Border.all(color: color.withOpacity(.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: color, size: 20),
            const SizedBox(width: 12),
            Text(name, style: AppTextStyles.body()),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
