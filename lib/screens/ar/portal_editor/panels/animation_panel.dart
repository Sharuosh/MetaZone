// File: lib/screens/ar/portal_editor/panels/animation_panel.dart
// MetaZone – Portal Animation Panel PRO (Portal-Compatible Version)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class AnimationPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const AnimationPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<AnimationPanel> createState() => _AnimationPanelState();
}

class _AnimationPanelState extends State<AnimationPanel> {
  late String animationId;
  late String trigger;
  late String curve;
  late double speed;
  late double intensity;

  final List<Map<String, String>> animations = [
    {"id": "idle_float", "label": "Idle Float"},
    {"id": "portal_spin", "label": "Portal Spin"},
    {"id": "pulse_glow", "label": "Pulse Glow"},
    {"id": "breathing", "label": "Breathing"},
    {"id": "hover_bounce", "label": "Hover Bounce"},
  ];

  final List<Map<String, String>> triggers = [
    {"id": "auto", "label": "Auto Play"},
    {"id": "on_enter", "label": "On Enter"},
    {"id": "on_tap", "label": "On Tap"},
  ];

  final List<Map<String, String>> curves = [
    {"id": "ease_in_out", "label": "Ease In Out"},
    {"id": "smooth", "label": "Smooth"},
    {"id": "elastic", "label": "Elastic"},
    {"id": "bounce", "label": "Bounce"},
  ];

  @override
  void initState() {
    super.initState();

    final anim = widget.config.animation ?? {};

    animationId = anim["id"] ?? "idle_float";
    trigger = anim["trigger"] ?? "auto";
    curve = anim["curve"] ?? "ease_in_out";
    speed = _num(anim["speed"], 1.0);
    intensity = _num(anim["intensity"], 0.5);
  }

  double _num(dynamic v, double fallback) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  void _emit() {
    final newAnim = {
      "id": animationId,
      "trigger": trigger,
      "curve": curve,
      "speed": speed,
      "intensity": intensity,
    };

    widget.onChanged(
      widget.config.copyWith(animation: newAnim),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Animation Style"),
          _animationSelector(),

          const SizedBox(height: 16),
          _title("Playback Trigger"),
          _dropdown(
            items: triggers,
            value: trigger,
            onChange: (v) {
              setState(() => trigger = v);
              _emit();
            },
          ),

          const SizedBox(height: 16),
          _title("Motion Curve"),
          _dropdown(
            items: curves,
            value: curve,
            onChange: (v) {
              setState(() => curve = v);
              _emit();
            },
          ),

          const SizedBox(height: 16),
          _title("Speed"),
          _slider(
            value: speed,
            min: 0.2,
            max: 3.0,
            onChange: (v) {
              setState(() => speed = v);
              _emit();
            },
          ),

          const SizedBox(height: 16),
          _title("Intensity"),
          _slider(
            value: intensity,
            min: 0.0,
            max: 1.0,
            onChange: (v) {
              setState(() => intensity = v);
              _emit();
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // Animation Selector
  // ==========================================================
  Widget _animationSelector() {
    return Column(
      children: animations.map((anim) {
        final id = anim["id"]!;
        final label = anim["label"]!;
        final active = id == animationId;

        return GestureDetector(
          onTap: () {
            setState(() => animationId = id);
            _emit();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: active
                  ? AppColors.primary.withOpacity(.18)
                  : AppColors.surface.withOpacity(.35),
              border: Border.all(
                color: active ? AppColors.primary : Colors.white12,
                width: active ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.motion_photos_on_rounded,
                  color: active ? AppColors.primary : Colors.white54,
                ),
                const SizedBox(width: 14),
                Text(label, style: AppTextStyles.body()),
                const Spacer(),
                if (active)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // Dropdown
  // ==========================================================
  Widget _dropdown({
    required List<Map<String, String>> items,
    required String value,
    required Function(String) onChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface.withOpacity(.4),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.card,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
        style: AppTextStyles.body(),
        items: items.map((i) {
          return DropdownMenuItem(
            value: i["id"],
            child: Text(i["label"]!),
          );
        }).toList(),
        onChanged: (v) => onChange(v!),
      ),
    );
  }

  // ==========================================================
  // Slider
  // ==========================================================
  Widget _slider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChange,
  }) {
    return Slider(
      value: value,
      min: min,
      max: max,
      activeColor: AppColors.primary,
      inactiveColor: Colors.white24,
      onChanged: onChange,
    );
  }

  // ==========================================================
  // Title
  // ==========================================================
  Widget _title(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: AppTextStyles.title(size: 16)));
}
