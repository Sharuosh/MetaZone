// File: lib/screens/ar/object_editor/panels/presets_panel.dart
// MetaZone – Presets Panel PRO (Material / Lighting / FX + User Saves)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PresetsPanel extends StatefulWidget {
  final Function(String category, String preset)? onPresetSelected;
  final Function(String name)? onSavePreset;

  const PresetsPanel({
    super.key,
    this.onPresetSelected,
    this.onSavePreset,
  });

  @override
  State<PresetsPanel> createState() => _PresetsPanelState();
}

class _PresetsPanelState extends State<PresetsPanel> {
  List<String> userPresets = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Presets", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 14),

          _category("Material Presets", _materialPresets()),
          const SizedBox(height: 18),

          _category("Lighting Presets", _lightingPresets()),
          const SizedBox(height: 18),

          _category("Effects Presets", _fxPresets()),
          const SizedBox(height: 18),

          _divider(),

          _savePresetButton(),
          const SizedBox(height: 12),

          if (userPresets.isNotEmpty)
            _category("My Saved Presets", _userPresetsList()),
        ],
      ),
    );
  }

  // ==============================================================
  // CATEGORY BUILDER
  // ==============================================================
  Widget _category(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.caption(size: 14)
                .copyWith(color: AppColors.primary)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // ==============================================================
  // MATERIAL PRESETS
  // ==============================================================
  Widget _materialPresets() {
    final presets = ["Metal", "Glass", "Neon", "Plastic", "Matte"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((p) => _presetChip("material", p)).toList(),
    );
  }

  // ==============================================================
  // LIGHTING PRESETS
  // ==============================================================
  Widget _lightingPresets() {
    final presets = ["Soft Light", "Hard Light", "Studio", "HDRI"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((p) => _presetChip("lighting", p)).toList(),
    );
  }

  // ==============================================================
  // FX PRESETS
  // ==============================================================
  Widget _fxPresets() {
    final presets = ["Glow", "Hologram", "Scanlines", "Portal Energy"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((p) => _presetChip("effects", p)).toList(),
    );
  }

  // ==============================================================
  // USER SAVED PRESETS
  // ==============================================================
  Widget _userPresetsList() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: userPresets.map((p) => _savedChip(p)).toList(),
    );
  }

  // ==============================================================
  // UNIVERSAL PRESET CHIP
  // ==============================================================
  Widget _presetChip(String category, String preset) {
    return GestureDetector(
      onTap: () => widget.onPresetSelected?.call(category, preset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.neonGradient,
          boxShadow: [
            BoxShadow(color: AppColors.primarySoft, blurRadius: 16),
          ],
        ),
        child: Text(
          preset,
          style: AppTextStyles.body(size: 13).copyWith(color: Colors.black),
        ),
      ),
    );
  }

  // ==============================================================
  // USER SAVED CHIP
  // ==============================================================
  Widget _savedChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface.withOpacity(.5),
        border: Border.all(color: AppColors.primary.withOpacity(.4)),
      ),
      child: Text(name, style: AppTextStyles.body(size: 13)),
    );
  }

  // ==============================================================
  // SAVE PRESET BUTTON
  // ==============================================================
  Widget _savePresetButton() {
    return GestureDetector(
      onTap: () => _openSaveDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(color: AppColors.primarySoft, blurRadius: 20)
          ],
        ),
        child: Center(
          child: Text(
            "Save Current Settings",
            style:
            AppTextStyles.title(size: 14).copyWith(color: Colors.black),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SAVE NAME DIALOG
  // ==============================================================
  void _openSaveDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text("Save Preset", style: AppTextStyles.title()),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Preset name",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() => userPresets.add(name));
                widget.onSavePreset?.call(name);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ==============================================================
  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: Colors.white12,
    );
  }
}
