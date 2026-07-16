// File: lib/screens/ar/portal_editor/panels/skybox_panel.dart
// MetaZone – Portal Skybox Panel PRO (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class SkyboxPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const SkyboxPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<SkyboxPanel> createState() => _SkyboxPanelState();
}

class _SkyboxPanelState extends State<SkyboxPanel> {
  late String skybox;
  late double brightness;
  late double contrast;
  late double saturation;

  final List<Map<String, dynamic>> skyboxes = [
    {"id": "galaxy", "label": "Galaxy", "thumb": "assets/skybox/galaxy.jpg"},
    {"id": "night", "label": "Night City", "thumb": "assets/skybox/night_city.jpg"},
    {"id": "desert", "label": "Desert", "thumb": "assets/skybox/desert.jpg"},
    {"id": "nebula", "label": "Nebula", "thumb": "assets/skybox/nebula.jpg"},
    {"id": "cyber", "label": "Cyberpunk", "thumb": "assets/skybox/cyberpunk.jpg"},
    {"id": "sunset", "label": "Sunset", "thumb": "assets/skybox/sunset.jpg"},
  ];

  @override
  void initState() {
    super.initState();

    final env = widget.config.environment is Map
        ? widget.config.environment as Map<String, dynamic>
        : {};

    skybox = env["skybox"] ?? "galaxy";
    brightness = _num(env["brightness"], 0.7);
    contrast = _num(env["contrast"], 0.5);
    saturation = _num(env["saturation"], 0.6);
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  void _emit() {
    final newEnv = {
      "skybox": skybox,
      "brightness": brightness,
      "contrast": contrast,
      "saturation": saturation,
    };

    widget.onChanged(
      widget.config.copyWith(environment: newEnv),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Skybox Environment"),
          const SizedBox(height: 12),

          _skyboxGrid(),
          const SizedBox(height: 20),

          _title("Atmosphere Tweaks"),
          const SizedBox(height: 12),

          _label("Brightness"),
          _slider(brightness, (v) {
            setState(() => brightness = v);
            _emit();
          }),

          const SizedBox(height: 12),
          _label("Contrast"),
          _slider(contrast, (v) {
            setState(() => contrast = v);
            _emit();
          }),

          const SizedBox(height: 12),
          _label("Saturation"),
          _slider(saturation, (v) {
            setState(() => saturation = v);
            _emit();
          }),

          const SizedBox(height: 20),
          _title("Presets"),
          _preset("Dream Galaxy", "galaxy", 0.9, 0.6, 0.8),
          _preset("Neon Cyber City", "cyber", 0.8, 0.65, 0.55),
          _preset("Soft Sunset", "sunset", 0.7, 0.5, 0.52),
        ],
      ),
    );
  }

  // SKYBOX GRID
  Widget _skyboxGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: skyboxes.map((s) {
        final active = s["id"] == skybox;

        return GestureDetector(
          onTap: () {
            setState(() => skybox = s["id"]);
            _emit();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? AppColors.primary : Colors.white12,
                width: active ? 2 : 1,
              ),
              image: DecorationImage(
                image: AssetImage(s["thumb"]),
                fit: BoxFit.cover,
                colorFilter: active
                    ? ColorFilter.mode(
                  AppColors.primary.withOpacity(.25),
                  BlendMode.overlay,
                )
                    : null,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    topRight: Radius.circular(10)),
                color: Colors.black38,
              ),
              child: Text(
                s["label"],
                style: AppTextStyles.caption(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // PRESET BUTTON
  Widget _preset(String label, String id, double b, double c, double s) {
    return GestureDetector(
      onTap: () {
        setState(() {
          skybox = id;
          brightness = b;
          contrast = c;
          saturation = s;
        });
        _emit();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface.withOpacity(.4),
          border: Border.all(color: AppColors.primary.withOpacity(.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body()),
            const Spacer(),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _slider(double v, Function(double) onChange) {
    return Slider(
      value: v,
      min: 0,
      max: 1,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
      onChanged: onChange,
    );
  }

  Widget _title(String t) =>
      Text(t, style: AppTextStyles.title(size: 16));

  Widget _label(String t) =>
      Text(t, style: AppTextStyles.caption(size: 14).copyWith(color: AppColors.primary));
}
