// File: lib/screens/ar/portal_editor/panels/sound_panel.dart
// MetaZone — Portal Sound Panel (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class SoundPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const SoundPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<SoundPanel> createState() => _SoundPanelState();
}

class _SoundPanelState extends State<SoundPanel> {
  late String ambient;
  late String sfx;

  late double ambientVolume;
  late double sfxVolume;
  late double spatialDepth;

  final ambientList = [
    {"id": "wind", "label": "Wind Breeze"},
    {"id": "sci_fi", "label": "Sci-Fi Hum"},
    {"id": "forest", "label": "Mystic Forest"},
    {"id": "cosmic", "label": "Cosmic Pulse"},
  ];

  final sfxList = [
    {"id": "portal_open", "label": "Portal Open"},
    {"id": "portal_close", "label": "Portal Close"},
    {"id": "energy_surge", "label": "Energy Surge"},
    {"id": "soft_chime", "label": "Soft Chime"},
  ];

  @override
  void initState() {
    super.initState();

    ambient = widget.config.sound["ambient"] ?? "wind";
    sfx = widget.config.sound["sfx"] ?? "portal_open";

    ambientVolume = widget.config.sound["ambient_volume"] ?? 0.6;
    sfxVolume = widget.config.sound["sfx_volume"] ?? 0.8;
    spatialDepth = widget.config.sound["spatial_depth"] ?? 0.5;
  }

  // -------------------------------------------------------------------
  // UPDATE PORTAL CONFIG
  // -------------------------------------------------------------------
  void _updateConfig() {
    final newSound = {
      "ambient": ambient,
      "sfx": sfx,
      "ambient_volume": ambientVolume,
      "sfx_volume": sfxVolume,
      "spatial_depth": spatialDepth,
    };

    widget.onChanged(
      widget.config.copyWith(sound: newSound),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Soundscape", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 12),

          // =====================================================================
          // Ambient
          // =====================================================================
          _section("Ambient Sound"),
          _soundSelector(
            list: ambientList,
            selectedId: ambient,
            onTap: (id) {
              setState(() => ambient = id);
              _updateConfig();
            },
          ),

          const SizedBox(height: 20),

          // =====================================================================
          // SFX
          // =====================================================================
          _section("SFX (Portal Actions)"),
          _soundSelector(
            list: sfxList,
            selectedId: sfx,
            onTap: (id) {
              setState(() => sfx = id);
              _updateConfig();
            },
          ),

          const SizedBox(height: 22),

          // =====================================================================
          // Volume Sliders
          // =====================================================================
          _section("Ambient Volume"),
          _slider(
            value: ambientVolume,
            onChange: (v) {
              setState(() => ambientVolume = v);
              _updateConfig();
            },
          ),

          const SizedBox(height: 18),

          _section("SFX Volume"),
          _slider(
            value: sfxVolume,
            onChange: (v) {
              setState(() => sfxVolume = v);
              _updateConfig();
            },
          ),

          const SizedBox(height: 18),

          _section("Spatial Depth"),
          _slider(
            value: spatialDepth,
            onChange: (v) {
              setState(() => spatialDepth = v);
              _updateConfig();
            },
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // SOUND SELECTOR
  // =====================================================================
  Widget _soundSelector({
    required List<Map<String, String>> list,
    required String selectedId,
    required Function(String) onTap,
  }) {
    return Column(
      children: list.map((sound) {
        final active = sound["id"] == selectedId;

        return GestureDetector(
          onTap: () => onTap(sound["id"]!),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? AppColors.primary : Colors.white12,
                width: active ? 2 : 1,
              ),
              color: active
                  ? AppColors.primary.withOpacity(.15)
                  : AppColors.surface.withOpacity(.3),
            ),
            child: Row(
              children: [
                Icon(Icons.multitrack_audio_rounded,
                    color: active ? AppColors.primary : Colors.white54),
                const SizedBox(width: 14),
                Text(sound["label"]!, style: AppTextStyles.body()),
                const Spacer(),
                if (active)
                  Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // =====================================================================
  // SLIDER
  // =====================================================================
  Widget _slider({
    required double value,
    required Function(double) onChange,
  }) {
    return Slider(
      value: value,
      min: 0,
      max: 1,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
      onChanged: onChange,
    );
  }

  // =====================================================================
  // SECTION TITLE
  // =====================================================================
  Widget _section(String text) {
    return Text(
      text,
      style: AppTextStyles.title(size: 15)
          .copyWith(color: AppColors.primary),
    );
  }
}
