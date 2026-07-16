// File: lib/screens/ar/portal_editor/panels/color_panel.dart
// MetaZone – Color Panel (Portal-Compatible 2025 Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class ColorPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const ColorPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<ColorPanel> createState() => _ColorPanelState();
}

class _ColorPanelState extends State<ColorPanel> {
  // PANEL STATE
  late String mode;

  late Color solidColor;
  late double opacity;

  late Color gradA;
  late Color gradB;

  late double glowIntensity;

  late Color holoTint;

  @override
  void initState() {
    super.initState();

    final colorData = widget.config.fx["color"] ?? {};

    mode = colorData["mode"] ?? "solid";

    solidColor = _parseColor(colorData["solid"]) ?? Colors.cyanAccent;
    opacity = (colorData["opacity"] ?? 1.0).toDouble();

    gradA = _parseColor(colorData["gradA"]) ?? Colors.deepPurpleAccent;
    gradB = _parseColor(colorData["gradB"]) ?? Colors.blueAccent;

    glowIntensity = (colorData["glowIntensity"] ?? 0.6).toDouble();

    holoTint = _parseColor(colorData["holoTint"]) ?? Colors.blueAccent;
  }

  // ----------------------------------------------------------
  // SAFE COLOR PARSER
  // ----------------------------------------------------------
  Color? _parseColor(dynamic v) {
    if (v is int) return Color(v);
    return null;
  }

  // ----------------------------------------------------------
  // EMIT BACK TO PORTAL CONFIG
  // ----------------------------------------------------------
  void _emit() {
    final newColorData = {
      "mode": mode,
      "solid": solidColor.value,
      "opacity": opacity,
      "gradA": gradA.value,
      "gradB": gradB.value,
      "glowIntensity": glowIntensity,
      "holoTint": holoTint.value,
    };

    final newFx = Map<String, dynamic>.from(widget.config.fx);
    newFx["color"] = newColorData;

    widget.onChanged(
      widget.config.copyWith(fx: newFx),
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
          _title("Color"),

          const SizedBox(height: 10),
          _subtitle("Mode"),
          Wrap(
            spacing: 8,
            children: [
              _modeButton("solid", "Solid"),
              _modeButton("gradient", "Gradient"),
              _modeButton("glow", "Neon Glow"),
              _modeButton("hologram", "Hologram Tint"),
            ],
          ),

          const SizedBox(height: 18),

          if (mode == "solid") _solidPanel(),
          if (mode == "gradient") _gradientPanel(),
          if (mode == "glow") _glowPanel(),
          if (mode == "hologram") _hologramPanel(),

          const SizedBox(height: 18),
          _subtitle("Meta Presets"),
          _presetColors(),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MODE BUTTON
  // ----------------------------------------------------------
  Widget _modeButton(String id, String label) {
    final active = mode == id;

    return GestureDetector(
      onTap: () {
        setState(() => mode = id);
        _emit();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.neonGradient : null,
          color: active ? null : AppColors.surface.withOpacity(.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.primarySoft
                : AppColors.border.withOpacity(.4),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption()
              .copyWith(color: active ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SOLID PANEL
  // ----------------------------------------------------------
  Widget _solidPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitle("Solid Color"),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () async {
            Color? newColor = await _pickColor(solidColor);
            if (newColor != null) {
              setState(() => solidColor = newColor);
              _emit();
            }
          },
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: solidColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
          ),
        ),

        const SizedBox(height: 14),
        _subtitle("Opacity"),

        Slider(
          value: opacity,
          min: 0.1,
          max: 1.0,
          activeColor: AppColors.primary,
          onChanged: (v) {
            setState(() => opacity = v);
            _emit();
          },
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // GRADIENT PANEL
  // ----------------------------------------------------------
  Widget _gradientPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitle("Gradient"),

        Row(
          children: [
            Expanded(child: _colorBox(gradA, (c) { gradA = c; })),
            const SizedBox(width: 12),
            Expanded(child: _colorBox(gradB, (c) { gradB = c; })),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: [gradA, gradB]),
          ),
        )
      ],
    );
  }

  // ----------------------------------------------------------
  // GLOW PANEL
  // ----------------------------------------------------------
  Widget _glowPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitle("Glow Strength"),

        Slider(
          min: 0.1,
          max: 1.5,
          value: glowIntensity,
          activeColor: AppColors.primary,
          onChanged: (v) {
            setState(() => glowIntensity = v);
            _emit();
          },
        ),

        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: solidColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: solidColor.withOpacity(.7),
                  blurRadius: 30 * glowIntensity,
                  spreadRadius: 5 * glowIntensity,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // HOLOGRAM PANEL
  // ----------------------------------------------------------
  Widget _hologramPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subtitle("Hologram Tint"),

        _colorBox(holoTint, (c) {
          holoTint = c;
        }),

        const SizedBox(height: 12),

        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                holoTint.withOpacity(.8),
                holoTint.withOpacity(.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // PRESETS
  // ----------------------------------------------------------
  Widget _presetColors() {
    final presets = [
      Colors.cyanAccent,
      Colors.deepPurpleAccent,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
      Colors.greenAccent,
    ];

    return Wrap(
      spacing: 10,
      children: presets.map((c) {
        return GestureDetector(
          onTap: () {
            setState(() => solidColor = c);
            _emit();
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------
  Widget _colorBox(Color color, Function(Color) setColor) {
    return GestureDetector(
      onTap: () async {
        final c = await _pickColor(color);
        if (c != null) {
          setState(() => setColor(c));
          _emit();
        }
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
      ),
    );
  }

  Future<Color?> _pickColor(Color base) async {
    return await showDialog<Color>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text("Pick Color", style: AppTextStyles.title()),
        content: Wrap(
          spacing: 10,
          children: [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.cyan,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ].map((c) {
            return GestureDetector(
              onTap: () => Navigator.pop(context, c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _title(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(t, style: AppTextStyles.title()));

  Widget _subtitle(String s) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(s, style: AppTextStyles.caption().copyWith(color: AppColors.primary)));
}
