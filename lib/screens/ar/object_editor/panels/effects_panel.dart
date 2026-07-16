// File: lib/screens/ar/object_editor/panels/effects_panel.dart
// MetaZone – Effects Panel PRO (Hologram, Glow, Distortion, Pulses)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EffectsPanel extends StatefulWidget {
  final Function(Map<String, dynamic> effectData)? onEffectsChanged;

  const EffectsPanel({super.key, this.onEffectsChanged});

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel> {
  double glow = 0.4;
  double hologram = 0.0;
  double distortion = 0.0;
  double pulseSpeed = 1.0;
  double opacity = 1.0;
  bool glitch = false;

  @override
  Widget build(BuildContext context) {
    _sendUpdate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Effects", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 16),

          _preview(),

          _title("Glow (Bloom)"),
          _slider(
            value: glow,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => glow = v),
          ),

          _title("Hologram Strength"),
          _slider(
            value: hologram,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => hologram = v),
          ),

          _title("Distortion (Refraction)"),
          _slider(
            value: distortion,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => distortion = v),
          ),

          _title("Pulse Speed"),
          _slider(
            value: pulseSpeed,
            min: 0.2,
            max: 3.0,
            onChanged: (v) => setState(() => pulseSpeed = v),
          ),

          _title("Opacity"),
          _slider(
            value: opacity,
            min: 0.1,
            max: 1.0,
            onChanged: (v) => setState(() => opacity = v),
          ),

          const SizedBox(height: 12),
          _switchTile("Enable Glitch FX", glitch,
                  (v) => setState(() => glitch = v)),
        ],
      ),
    );
  }

  // ==========================================================
  // SEND UPDATE TO ENGINE / UNITY
  // ==========================================================
  void _sendUpdate() {
    widget.onEffectsChanged?.call({
      "glow": glow,
      "hologram": hologram,
      "distortion": distortion,
      "pulseSpeed": pulseSpeed,
      "opacity": opacity,
      "glitch": glitch,
    });
  }

  // ==========================================================
  // FX PREVIEW BOX
  // ==========================================================
  Widget _preview() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 60,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(glow),
            blurRadius: 26 * glow,
            spreadRadius: 6 * glow,
          )
        ],
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(hologram * 0.6 + .1),
            Colors.purpleAccent.withOpacity(distortion * 0.6 + .1),
            Colors.cyan.withOpacity(opacity * 0.3),
          ],
        ),
        border: Border.all(color: Colors.white30),
      ),
    );
  }

  // ==========================================================
  // UI COMPONENTS
  // ==========================================================
  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style:
        AppTextStyles.caption().copyWith(color: AppColors.primary),
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
