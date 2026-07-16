// File: lib/screens/ar/portal_editor/panels/portal_core_panel.dart
// MetaZone – Portal Core Panel (Portal-Compatible Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class CorePanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const CorePanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<CorePanel> createState() => _CorePanelState();
}

class _CorePanelState extends State<CorePanel> {
  late bool enableVortex;
  late bool enableEnergy;
  late bool enableDepth;

  late double vortexIntensity;
  late double energyPulse;
  late double depthLevel;
  late double glowPower;

  @override
  void initState() {
    super.initState();

    final fx = widget.config.fx;

    enableVortex = fx["enableVortex"] ?? true;
    enableEnergy = fx["enableEnergy"] ?? true;
    enableDepth = fx["enableDepth"] ?? true;

    vortexIntensity = _num(fx["vortexIntensity"], 0.4);
    energyPulse = _num(fx["energyPulse"], 0.5);
    depthLevel = _num(fx["depthLevel"], 0.6);
    glowPower = _num(fx["glowPower"], 0.3);
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  // ------------------------------------------------------------
  // EMIT CHANGES TO CONFIG
  // ------------------------------------------------------------
  void _emit() {
    final newFX = Map<String, dynamic>.from(widget.config.fx);

    newFX["enableVortex"] = enableVortex;
    newFX["enableEnergy"] = enableEnergy;
    newFX["enableDepth"] = enableDepth;

    newFX["vortexIntensity"] = vortexIntensity;
    newFX["energyPulse"] = energyPulse;
    newFX["depthLevel"] = depthLevel;
    newFX["glowPower"] = glowPower;

    widget.onChanged(
      widget.config.copyWith(fx: newFX),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Portal Core Engine"),

          const SizedBox(height: 12),

          _toggle("Enable Vortex Field", enableVortex, (v) {
            setState(() => enableVortex = v);
            _emit();
          }),

          if (enableVortex)
            _slider("Vortex Strength", vortexIntensity, (v) {
              setState(() => vortexIntensity = v);
              _emit();
            }),

          const SizedBox(height: 18),

          _toggle("Energy Pulse", enableEnergy, (v) {
            setState(() => enableEnergy = v);
            _emit();
          }),

          if (enableEnergy)
            _slider("Pulse Intensity", energyPulse, (v) {
              setState(() => energyPulse = v);
              _emit();
            }),

          const SizedBox(height: 18),

          _toggle("Depth Simulation", enableDepth, (v) {
            setState(() => enableDepth = v);
            _emit();
          }),

          if (enableDepth)
            _slider("Depth Level", depthLevel, (v) {
              setState(() => depthLevel = v);
              _emit();
            }),

          const SizedBox(height: 18),

          _slider("Glow Power", glowPower, (v) {
            setState(() => glowPower = v);
            _emit();
          }),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UI COMPONENTS
  // ------------------------------------------------------------
  Widget _title(String text) {
    return Text(text, style: AppTextStyles.title(size: 18));
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.body())),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _slider(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption(size: 13)
                  .copyWith(color: AppColors.primary)),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 100,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
