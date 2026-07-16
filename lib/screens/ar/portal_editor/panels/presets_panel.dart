// File: lib/screens/ar/portal_editor/panels/presets_panel.dart
// MetaZone – Portal Presets Panel (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class PresetsPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const PresetsPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<PresetsPanel> createState() => _PresetsPanelState();
}

class _PresetsPanelState extends State<PresetsPanel> {
  late List<Map<String, dynamic>> builtInPresets;
  late Map<String, dynamic> userPresets;

  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    builtInPresets = [
      {
        "name": "Cyber Neon",
        "color": Colors.cyanAccent.value,
        "glow": 0.8,
        "texture": "neon_grid",
        "animation": "pulse",
      },
      {
        "name": "Ancient Portal",
        "color": Colors.amber.value,
        "glow": 0.2,
        "texture": "stone_runic",
        "animation": "slow_breath",
      },
      {
        "name": "Galaxy Rift",
        "color": Colors.purpleAccent.value,
        "glow": 1.0,
        "texture": "galaxy_core",
        "animation": "warp",
      },
    ];

    // Load user presets from PortalConfig
    userPresets = Map<String, dynamic>.from(widget.config.presets);
  }

  // -------------------------------------------------------------
  // APPLY PRESET TO PORTALCONFIG
  // -------------------------------------------------------------
  void _applyPreset(Map<String, dynamic> preset) {
    final updated = widget.config.copyWith(
      surface: preset["texture"] ?? widget.config.surface,
      animation: {
        ...widget.config.animation,
        "preset_animation": preset["animation"],
      },
      fx: {
        ...widget.config.fx,
        "glowIntensity": preset["glow"] ?? widget.config.fx["glowIntensity"],
      },
    );

    widget.onChanged(updated);
  }

  // -------------------------------------------------------------
  // SAVE NEW PRESET (IN config.presets)
  // -------------------------------------------------------------
  void _savePreset() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final presetData = {
      "color": Colors.white.value,
      "glow": 0.5,
      "texture": "custom_texture",
      "animation": "none",
    };

    final updatedPresets = Map<String, dynamic>.from(userPresets);
    updatedPresets[name] = presetData;

    // Save to PortalConfig
    widget.onChanged(
      widget.config.copyWith(presets: updatedPresets),
    );

    setState(() {
      userPresets = updatedPresets;
    });

    _nameCtrl.clear();
  }

  // -------------------------------------------------------------
  // DELETE PRESET
  // -------------------------------------------------------------
  void _deletePreset(String name) {
    final updated = Map<String, dynamic>.from(userPresets);
    updated.remove(name);

    widget.onChanged(
      widget.config.copyWith(presets: updated),
    );

    setState(() {
      userPresets = updated;
    });
  }

  // -------------------------------------------------------------
  // UI BUILD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Portal Presets", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 14),

          _section("Built-in Presets"),
          const SizedBox(height: 8),
          _presetList(builtInPresets, builtIn: true),

          const SizedBox(height: 20),
          _section("My Presets"),
          const SizedBox(height: 8),
          _presetList(userPresets.entries.toList(), builtIn: false),

          const SizedBox(height: 14),
          _savePresetButton(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PRESETS LIST
  // -------------------------------------------------------------
  Widget _presetList(dynamic list, {required bool builtIn}) {
    if (!builtIn && list.isEmpty) {
      return Text("No custom presets yet.", style: AppTextStyles.caption());
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final p = builtIn ? list[i] : list[i].value;

          return GestureDetector(
            onTap: () => _applyPreset(p),
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(p["color"]).withOpacity(.6),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(p["color"]).withOpacity(.25),
                    Colors.black.withOpacity(.25),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(p["color"]).withOpacity(.45),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p["name"] ?? list[i].key,
                      style: AppTextStyles.title(size: 14)),
                  const SizedBox(height: 6),
                  _previewBubble(p),
                  const Spacer(),
                  if (!builtIn)
                    GestureDetector(
                      onTap: () => _deletePreset(list[i].key),
                      child:
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _previewBubble(Map<String, dynamic> p) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: RadialGradient(
          colors: [
            Color(p["color"]),
            Colors.black,
          ],
          radius: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          p["texture"].toString(),
          style:
          AppTextStyles.caption(size: 11).copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _savePresetButton() {
    return GestureDetector(
      onTap: _openSaveDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            "Save Current as Preset",
            style: AppTextStyles.body(size: 14).copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // SAVE DIALOG
  // -------------------------------------------------------------
  void _openSaveDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: AppColors.card.withOpacity(.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Save Preset", style: AppTextStyles.title(size: 16)),
                const SizedBox(height: 12),

                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Preset name",
                    hintStyle: AppTextStyles.caption(),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _savePreset();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.neonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Save",
                        style: AppTextStyles.body(size: 14)
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _section(String t) => Text(
    t,
    style: AppTextStyles.caption(size: 14)
        .copyWith(color: AppColors.primary),
  );
}
