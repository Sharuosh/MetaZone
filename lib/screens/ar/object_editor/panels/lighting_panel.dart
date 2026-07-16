// File: lib/screens/ar/object_editor/panels/lighting_panel.dart
// MetaZone – Lighting Panel PRO (Future-Ready for Unity)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LightingPanel extends StatefulWidget {
  final Function(Map<String, dynamic> lightData)? onLightingChanged;

  const LightingPanel({super.key, this.onLightingChanged});

  @override
  State<LightingPanel> createState() => _LightingPanelState();
}

class _LightingPanelState extends State<LightingPanel> {
  double intensity = 1.0;
  double direction = 45.0;
  double temperature = 6500; // Neutral daylight
  double ambient = 0.3;
  double rimLight = 0.2;
  bool shadows = true;

  @override
  Widget build(BuildContext context) {
    _sendUpdate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Lighting", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 14),

          _previewLight(),

          _title("Intensity"),
          _slider(
            value: intensity,
            min: 0.0,
            max: 3.0,
            onChanged: (v) => setState(() => intensity = v),
          ),

          _title("Direction"),
          _slider(
            value: direction,
            min: 0,
            max: 360,
            onChanged: (v) => setState(() => direction = v),
          ),

          _title("Color Temperature (${temperature.toInt()}K)"),
          _slider(
            value: temperature,
            min: 2000,
            max: 9000,
            onChanged: (v) => setState(() => temperature = v),
          ),

          _title("Ambient Light"),
          _slider(
            value: ambient,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => ambient = v),
          ),

          _title("Rim Light"),
          _slider(
            value: rimLight,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => rimLight = v),
          ),

          const SizedBox(height: 6),
          _switchTile(
            "Enable Shadows",
            shadows,
                (v) => setState(() => shadows = v),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEND UPDATE TO EDITOR (UNITY / ENGINE)
  // ==========================================================
  void _sendUpdate() {
    widget.onLightingChanged?.call({
      "intensity": intensity,
      "direction": direction,
      "temperature": temperature,
      "ambient": ambient,
      "rimLight": rimLight,
      "shadows": shadows,
    });
  }

  // ==========================================================
  // PREVIEW BOX (LIGHT FEEL EFFECT)
  // ==========================================================
  Widget _previewLight() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(intensity.clamp(0.1, 1.0)),
            Colors.orange.withOpacity(intensity * 0.3),
            Colors.black.withOpacity(.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  // ==========================================================
  // CUSTOM UI ELEMENTS
  // ==========================================================
  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.caption().copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _slider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
    );
  }

  Widget _switchTile(String text, bool val, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(text, style: AppTextStyles.body()),
        ),
        Switch(
          value: val,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        )
      ],
    );
  }
}
