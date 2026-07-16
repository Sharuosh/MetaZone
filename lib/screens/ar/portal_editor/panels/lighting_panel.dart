// File: lib/screens/ar/portal_editor/panels/lighting_panel.dart
// MetaZone – Portal Lighting Panel (Portal-Compatible PRO Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class LightingPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const LightingPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<LightingPanel> createState() => _LightingPanelState();
}

class _LightingPanelState extends State<LightingPanel> {
  late double globalLight;
  late double rimIntensity;
  late double bloom;
  late double shadowSoftness;
  late double ambientOcclusion;
  late double temperature;

  @override
  void initState() {
    super.initState();

    final l = widget.config.lighting;

    globalLight = _num(l["globalLight"], 0.8);
    rimIntensity = _num(l["rimIntensity"], 0.4);
    bloom = _num(l["bloom"], 0.3);
    shadowSoftness = _num(l["shadowSoftness"], 0.6);
    ambientOcclusion = _num(l["ao"], 0.5);
    temperature = _num(l["temperature"], 6500);
  }

  double _num(dynamic v, double fallback) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return fallback;
  }

  /// 🔥 Emit merged config
  void _emit() {
    final updatedLighting = {
      "globalLight": globalLight,
      "rimIntensity": rimIntensity,
      "bloom": bloom,
      "shadowSoftness": shadowSoftness,
      "ao": ambientOcclusion,
      "temperature": temperature,
    };

    widget.onChanged(
      widget.config.copyWith(lighting: updatedLighting),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lighting", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 18),

          _section("Global Light"),
          _slider(globalLight, 0, 1, (v) {
            setState(() => globalLight = v);
            _emit();
          }),

          _section("Rim Light (Outline Glow)"),
          _slider(rimIntensity, 0, 1, (v) {
            setState(() => rimIntensity = v);
            _emit();
          }),

          _section("Bloom / Glow"),
          _slider(bloom, 0, 1, (v) {
            setState(() => bloom = v);
            _emit();
          }),

          _section("Shadow Softness"),
          _slider(shadowSoftness, 0, 1, (v) {
            setState(() => shadowSoftness = v);
            _emit();
          }),

          _section("Ambient Occlusion"),
          _slider(ambientOcclusion, 0, 1, (v) {
            setState(() => ambientOcclusion = v);
            _emit();
          }),

          _section("Light Temperature (Kelvin)"),
          _tempSlider(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // UI Components
  // ----------------------------------------------------------

  Widget _section(String txt) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        txt,
        style: AppTextStyles.caption()
            .copyWith(color: AppColors.primary, fontSize: 13),
      ),
    );
  }

  Widget _slider(double value, double min, double max, Function(double) onChange) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) => onChange(v),
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ),
        const SizedBox(width: 10),
        Text(value.toStringAsFixed(2), style: AppTextStyles.caption(size: 12)),
      ],
    );
  }

  Widget _tempSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: temperature,
          min: 1000,
          max: 12000,
          onChanged: (v) {
            setState(() => temperature = v);
            _emit();
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
        Text("${temperature.toInt()} K", style: AppTextStyles.caption()),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Warm", style: TextStyle(color: Colors.orangeAccent)),
            Text("Neutral", style: TextStyle(color: Colors.white70)),
            Text("Cool", style: TextStyle(color: Colors.lightBlueAccent)),
          ],
        ),
      ],
    );
  }
}
