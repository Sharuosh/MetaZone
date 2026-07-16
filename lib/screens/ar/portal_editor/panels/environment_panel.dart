// File: lib/screens/ar/portal_editor/panels/environment_panel.dart
// MetaZone – Environment Panel (Portal-Compatible FINAL VERSION)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class EnvironmentPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const EnvironmentPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<EnvironmentPanel> createState() => _EnvironmentPanelState();
}

class _EnvironmentPanelState extends State<EnvironmentPanel> {
  late double fogDensity;
  late double fogDistance;

  late double ambientLight;
  late double directionalLight;
  late double lightRotation;

  late double environmentTemp;
  late String selectedSkybox;

  final List<String> skyboxes = [
    "Nebula",
    "Dark Space",
    "Blue Galaxy",
    "Sunset Horizon",
    "Cyber Grid",
  ];

  @override
  void initState() {
    super.initState();

    // Safe fallback (ensures no null map crash)
    final env = (widget.config.environment ?? <String, dynamic>{});

    fogDensity = _num(env["fogDensity"], 0.0);
    fogDistance = _num(env["fogDistance"], 15.0);

    ambientLight = _num(env["ambientLight"], 0.6);
    directionalLight = _num(env["directionalLight"], 0.8);
    lightRotation = _num(env["lightRotation"], 45.0);

    environmentTemp = _num(env["environmentTemp"], 6500);

    selectedSkybox = (env["skybox"] is String) ? env["skybox"] : "Nebula";
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  // Emit new environment config → PortalConfig
  void _emit() {
    final newEnv = {
      "fogDensity": fogDensity,
      "fogDistance": fogDistance,
      "ambientLight": ambientLight,
      "directionalLight": directionalLight,
      "lightRotation": lightRotation,
      "environmentTemp": environmentTemp,
      "skybox": selectedSkybox,
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
          _title("Environment"),

          const SizedBox(height: 18),
          _subTitle("Skybox"),
          _skyboxSelector(),

          const SizedBox(height: 18),
          _subTitle("Lighting"),
          _lightingControls(),

          const SizedBox(height: 18),
          _subTitle("Fog Settings"),
          _fogControls(),

          const SizedBox(height: 18),
          _subTitle("Color Temperature"),
          _temperatureSlider(),
        ],
      ),
    );
  }

  // SKYBOX PICKER
  Widget _skyboxSelector() {
    return Column(
      children: skyboxes.map((box) {
        bool active = selectedSkybox == box;

        return GestureDetector(
          onTap: () {
            setState(() => selectedSkybox = box);
            _emit();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: active ? AppColors.neonGradient : null,
              color: active ? null : AppColors.surface.withOpacity(.4),
              boxShadow: active
                  ? [
                BoxShadow(
                  color: AppColors.primarySoft,
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(Icons.wallpaper_rounded,
                    color: active ? Colors.black : Colors.white70),
                const SizedBox(width: 12),
                Text(
                  box,
                  style: AppTextStyles.body().copyWith(
                    color: active ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // LIGHTING
  Widget _lightingControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Ambient Light"),
        _slider(
          ambientLight,
              (v) {
            setState(() => ambientLight = v);
            _emit();
          },
        ),

        const SizedBox(height: 12),
        _label("Directional Light"),
        _slider(
          directionalLight,
              (v) {
            setState(() => directionalLight = v);
            _emit();
          },
        ),

        const SizedBox(height: 12),
        _label("Light Rotation (°)"),
        _slider(
          lightRotation,
              (v) {
            setState(() => lightRotation = v);
            _emit();
          },
          max: 360,
        ),
      ],
    );
  }

  // FOG
  Widget _fogControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Fog Density"),
        _slider(
          fogDensity,
              (v) {
            setState(() => fogDensity = v);
            _emit();
          },
          max: 1.0,
        ),

        const SizedBox(height: 12),
        _label("Fog Distance"),
        _slider(
          fogDistance,
              (v) {
            setState(() => fogDistance = v);
            _emit();
          },
          max: 100.0,
        ),
      ],
    );
  }

  // COLOR TEMP
  Widget _temperatureSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Temperature: ${environmentTemp.round()}K"),

        Slider(
          value: environmentTemp,
          min: 2000,
          max: 10000,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
          onChanged: (v) {
            setState(() => environmentTemp = v);
            _emit();
          },
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Warm", style: TextStyle(color: Colors.white70)),
            Text("Neutral", style: TextStyle(color: Colors.white70)),
            Text("Cold", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ],
    );
  }

  // HELPERS
  Widget _title(String t) =>
      Text(t, style: AppTextStyles.title(size: 18));

  Widget _subTitle(String t) => Text(
    t,
    style:
    AppTextStyles.title(size: 14).copyWith(color: AppColors.primary),
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: AppTextStyles.caption(size: 12)),
  );

  Widget _slider(double value, Function(double) onChanged,
      {double min = 0, double max = 1}) {
    return Slider(
      value: value,
      min: min,
      max: max,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
      onChanged: onChanged,
    );
  }
}
