// File: lib/screens/ar/object_editor/panels/color_panel.dart
// MetaZone – Color Panel PRO (Future-Ready for Unity)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ColorPanel extends StatefulWidget {
  final Function(Color color)? onColorChanged;

  const ColorPanel({super.key, this.onColorChanged});

  @override
  State<ColorPanel> createState() => _ColorPanelState();
}

class _ColorPanelState extends State<ColorPanel> {
  double hue = 200;
  double saturation = 0.7;
  double brightness = 0.9;
  double opacity = 1.0;

  Color get currentColor =>
      HSVColor.fromAHSV(opacity, hue, saturation, brightness).toColor();

  @override
  Widget build(BuildContext context) {
    widget.onColorChanged?.call(currentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color", style: AppTextStyles.title(size: 18)),
        const SizedBox(height: 14),

        _previewBox(),
        const SizedBox(height: 18),

        _sectionTitle("Hue"),
        _slider(
          value: hue,
          min: 0,
          max: 360,
          onChanged: (v) => setState(() => hue = v),
          active: Colors.red,
        ),

        _sectionTitle("Saturation"),
        _slider(
          value: saturation,
          min: 0,
          max: 1,
          onChanged: (v) => setState(() => saturation = v),
          active: Colors.purple,
        ),

        _sectionTitle("Brightness"),
        _slider(
          value: brightness,
          min: 0,
          max: 1,
          onChanged: (v) => setState(() => brightness = v),
          active: Colors.yellow,
        ),

        _sectionTitle("Opacity"),
        _slider(
          value: opacity,
          min: 0.1,
          max: 1.0,
          onChanged: (v) => setState(() => opacity = v),
          active: Colors.white,
        ),

        const SizedBox(height: 18),
        _presetColors(),
      ],
    );
  }

  // ==========================================================
  // PREVIEW BOX
  // ==========================================================
  Widget _previewBox() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: currentColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
    );
  }

  // ==========================================================
  // PRESET QUICK COLORS
  // ==========================================================
  Widget _presetColors() {
    final presets = [
      Colors.white,
      Colors.black,
      Colors.blueAccent,
      Colors.deepPurpleAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((c) {
        return GestureDetector(
          onTap: () => setState(() {
            final hsv = HSVColor.fromColor(c);
            hue = hsv.hue;
            saturation = hsv.saturation;
            brightness = hsv.value;
            opacity = hsv.alpha;
          }),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white30),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // SLIDER
  // ==========================================================
  Widget _slider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required Color active,
  }) {
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      activeColor: active,
      inactiveColor: Colors.white24,
    );
  }

  // ==========================================================
  // TITLE
  // ==========================================================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(text,
          style:
          AppTextStyles.caption(size: 12).copyWith(color: AppColors.primary)),
    );
  }
}
