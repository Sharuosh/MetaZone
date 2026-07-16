// File: lib/screens/ar/object_editor/panels/physics_panel.dart
// MetaZone – Physics Panel PRO (Advanced AR Physics Controls)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PhysicsPanel extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPhysicsChanged;

  const PhysicsPanel({super.key, this.onPhysicsChanged});

  @override
  State<PhysicsPanel> createState() => _PhysicsPanelState();
}

class _PhysicsPanelState extends State<PhysicsPanel> {
  bool usePhysics = true;
  bool enableCollisions = true;

  double mass = 1.0;
  double bounciness = 0.2;
  double friction = 0.4;
  double gravity = 1.0;
  double airDrag = 0.1;
  double surfaceStick = 0.0;

  bool freezeX = false;
  bool freezeY = false;
  bool freezeZ = false;

  @override
  Widget build(BuildContext context) {
    _sendUpdate();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Physics", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 14),

          _switch("Enable Physics", usePhysics,
                  (v) => setState(() => usePhysics = v)),

          _switch("Enable Collisions", enableCollisions,
                  (v) => setState(() => enableCollisions = v)),

          const SizedBox(height: 14),
          _divider(),

          _label("Mass"),
          _slider(
            value: mass,
            min: 0.1,
            max: 10,
            onChanged: (v) => setState(() => mass = v),
          ),

          _label("Bounciness"),
          _slider(
            value: bounciness,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => bounciness = v),
          ),

          _label("Friction"),
          _slider(
            value: friction,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => friction = v),
          ),

          _label("Gravity Strength"),
          _slider(
            value: gravity,
            min: 0,
            max: 2,
            onChanged: (v) => setState(() => gravity = v),
          ),

          _label("Air Resistance"),
          _slider(
            value: airDrag,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => airDrag = v),
          ),

          _label("Surface Stickiness"),
          _slider(
            value: surfaceStick,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => surfaceStick = v),
          ),

          const SizedBox(height: 12),
          _divider(),

          Text("Freeze Axes", style: AppTextStyles.caption()),
          const SizedBox(height: 8),

          Row(
            children: [
              _freezeBox("X", freezeX, (v) => setState(() => freezeX = v)),
              const SizedBox(width: 8),
              _freezeBox("Y", freezeY, (v) => setState(() => freezeY = v)),
              const SizedBox(width: 8),
              _freezeBox("Z", freezeZ, (v) => setState(() => freezeZ = v)),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEND UPDATE MAP
  // ==========================================================
  void _sendUpdate() {
    widget.onPhysicsChanged?.call({
      "enabled": usePhysics,
      "collisions": enableCollisions,
      "mass": mass,
      "bounce": bounciness,
      "friction": friction,
      "gravity": gravity,
      "airDrag": airDrag,
      "stick": surfaceStick,
      "freeze": {
        "x": freezeX,
        "functions.mz": freezeY,
        "z": freezeZ,
      }
    });
  }

  // ==========================================================
  // UI COMPONENTS
  // ==========================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.caption(size: 13)
            .copyWith(color: AppColors.primary),
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

  Widget _switch(String text, bool val, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
            child: Text(text, style: AppTextStyles.body(size: 14))),
        Switch(
          value: val,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        )
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: Colors.white12,
    );
  }

  Widget _freezeBox(String axis, bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value
              ? AppColors.primary
              : AppColors.surface.withOpacity(.4),
          border: Border.all(
              color: value
                  ? AppColors.primarySoft
                  : Colors.white24,
              width: 1.2),
        ),
        child: Text(
          axis,
          style: AppTextStyles.title(size: 14)
              .copyWith(color: value ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
