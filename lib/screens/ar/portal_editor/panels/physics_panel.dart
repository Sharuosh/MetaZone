// File: lib/screens/ar/portal_editor/panels/physics_panel.dart
// MetaZone – Portal Physics Panel (Portal-ready, fully compatible with PortalConfig)
// Integrates with PortalEditorScreen via:
//   PortalPhysicsPanel(config: config, onChanged: updateConfig)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class PortalPhysicsPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const PortalPhysicsPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<PortalPhysicsPanel> createState() => _PortalPhysicsPanelState();
}

class _PortalPhysicsPanelState extends State<PortalPhysicsPanel> {
  // mirrored local state (initialized from config.physics)
  late double mass;
  late double gravityScale;
  late double linearDamping;
  late double angularDamping;

  late String collisionShape;
  late bool collisionEnabled;
  late double bounciness;
  late double friction;

  late bool softBody;
  late double softness;
  late double structuralStiffness;

  late bool lockPositionX;
  late bool lockPositionY;
  late bool lockPositionZ;
  late bool lockRotationX;
  late bool lockRotationY;
  late bool lockRotationZ;

  late double windStrength;
  late double drag;

  late String preset;

  final List<String> _collisionOptions = [
    "Convex Mesh",
    "Concave Mesh",
    "Box",
    "Sphere",
    "Capsule",
    "None"
  ];

  final List<String> _presets = [
    "Default",
    "Static (Fixed)",
    "Lightweight (Feather)",
    "Bouncy (Rubber)",
    "Heavy (Iron)",
    "Jelly (SoftBody)"
  ];

  @override
  void initState() {
    super.initState();
    final physics = widget.config.physics;

    // Safe extraction with fallbacks
    mass = _toDouble(physics["mass"], 1.0);
    gravityScale = _toDouble(physics["gravityScale"], 1.0);
    linearDamping = _toDouble(physics["linearDamping"], 0.05);
    angularDamping = _toDouble(physics["angularDamping"], 0.05);

    collisionShape = (physics["collisionShape"] ?? "Convex Mesh") as String;
    collisionEnabled = (physics["collisionEnabled"] ?? true) as bool;
    bounciness = _toDouble(physics["bounciness"], 0.15);
    friction = _toDouble(physics["friction"], 0.45);

    softBody = (physics["softBody"] ?? false) as bool;
    softness = _toDouble(physics["softness"], 0.25);
    structuralStiffness = _toDouble(physics["structuralStiffness"], 0.6);

    lockPositionX = (physics["lockPositionX"] ?? false) as bool;
    lockPositionY = (physics["lockPositionY"] ?? false) as bool;
    lockPositionZ = (physics["lockPositionZ"] ?? false) as bool;
    lockRotationX = (physics["lockRotationX"] ?? false) as bool;
    lockRotationY = (physics["lockRotationY"] ?? false) as bool;
    lockRotationZ = (physics["lockRotationZ"] ?? false) as bool;

    windStrength = _toDouble(physics["windStrength"], 0.0);
    drag = _toDouble(physics["drag"], 0.0);

    preset = (physics["preset"] ?? "Default") as String;
  }

  double _toDouble(dynamic v, double fallback) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return fallback;
  }

  // build a new PortalConfig with updated physics map and call callback
  void _emitPhysicsUpdate([String? changedKey]) {
    final newPhysics = Map<String, dynamic>.from(widget.config.physics);
    newPhysics["mass"] = mass;
    newPhysics["gravityScale"] = gravityScale;
    newPhysics["linearDamping"] = linearDamping;
    newPhysics["angularDamping"] = angularDamping;

    newPhysics["collisionShape"] = collisionShape;
    newPhysics["collisionEnabled"] = collisionEnabled;
    newPhysics["bounciness"] = bounciness;
    newPhysics["friction"] = friction;

    newPhysics["softBody"] = softBody;
    newPhysics["softness"] = softness;
    newPhysics["structuralStiffness"] = structuralStiffness;

    newPhysics["lockPositionX"] = lockPositionX;
    newPhysics["lockPositionY"] = lockPositionY;
    newPhysics["lockPositionZ"] = lockPositionZ;
    newPhysics["lockRotationX"] = lockRotationX;
    newPhysics["lockRotationY"] = lockRotationY;
    newPhysics["lockRotationZ"] = lockRotationZ;

    newPhysics["windStrength"] = windStrength;
    newPhysics["drag"] = drag;

    newPhysics["preset"] = preset;

    widget.onChanged(widget.config.copyWith(physics: newPhysics));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Physics", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 12),

          // Presets
          _label("Presets"),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: preset,
                  decoration: const InputDecoration(isDense: true),
                  items: _presets
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      preset = v;
                      _applyPreset(v);
                    });
                    _emitPhysicsUpdate("preset");
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _quickSavePreset,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          // Core dynamics
          _label("Core Dynamics"),
          _sliderRow(
            "Mass (kg)",
            mass,
            0.01,
            200.0,
                (v) => setState(() => mass = v),
            onChangeEnd: (_) => _emitPhysicsUpdate("mass"),
          ),
          _sliderRow(
            "Gravity Scale",
            gravityScale,
            0.0,
            2.0,
                (v) => setState(() => gravityScale = v),
            onChangeEnd: (_) => _emitPhysicsUpdate("gravityScale"),
          ),
          _sliderRow(
            "Linear Damping",
            linearDamping,
            0.0,
            2.0,
                (v) => setState(() => linearDamping = v),
            onChangeEnd: (_) => _emitPhysicsUpdate("linearDamping"),
          ),
          _sliderRow(
            "Angular Damping",
            angularDamping,
            0.0,
            2.0,
                (v) => setState(() => angularDamping = v),
            onChangeEnd: (_) => _emitPhysicsUpdate("angularDamping"),
          ),

          const SizedBox(height: 12),

          // Collision
          _label("Collision"),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: collisionShape,
                  decoration: const InputDecoration(isDense: true),
                  items: _collisionOptions
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => collisionShape = v);
                    _emitPhysicsUpdate("collisionShape");
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text("Enabled", style: AppTextStyles.caption()),
                  Switch(
                    value: collisionEnabled,
                    onChanged: (v) {
                      setState(() => collisionEnabled = v);
                      _emitPhysicsUpdate("collisionEnabled");
                    },
                  ),
                ],
              ),
            ],
          ),
          _sliderRow("Bounciness", bounciness, 0.0, 1.0,
                  (v) => setState(() => bounciness = v),
              onChangeEnd: (_) => _emitPhysicsUpdate("bounciness")),
          _sliderRow("Friction", friction, 0.0, 1.0,
                  (v) => setState(() => friction = v),
              onChangeEnd: (_) => _emitPhysicsUpdate("friction")),

          const SizedBox(height: 12),

          // Soft body / cloth
          _label("Soft-body & Cloth"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Enable Soft-body", style: AppTextStyles.body()),
              Switch(
                value: softBody,
                onChanged: (v) {
                  setState(() => softBody = v);
                  _emitPhysicsUpdate("softBody");
                },
              )
            ],
          ),
          if (softBody) ...[
            _sliderRow("Softness", softness, 0.0, 1.0,
                    (v) => setState(() => softness = v),
                onChangeEnd: (_) => _emitPhysicsUpdate("softness")),
            _sliderRow(
                "Structural Stiffness",
                structuralStiffness,
                0.0,
                1.0,
                    (v) => setState(() => structuralStiffness = v),
                onChangeEnd: (_) => _emitPhysicsUpdate("structuralStiffness")),
          ],

          const SizedBox(height: 12),

          // Constraints
          _label("Constraints (Lock axes)"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _axisLockChip("PX", lockPositionX, () {
                setState(() => lockPositionX = !lockPositionX);
                _emitPhysicsUpdate("lockPositionX");
              }),
              _axisLockChip("PY", lockPositionY, () {
                setState(() => lockPositionY = !lockPositionY);
                _emitPhysicsUpdate("lockPositionY");
              }),
              _axisLockChip("PZ", lockPositionZ, () {
                setState(() => lockPositionZ = !lockPositionZ);
                _emitPhysicsUpdate("lockPositionZ");
              }),
              _axisLockChip("RX", lockRotationX, () {
                setState(() => lockRotationX = !lockRotationX);
                _emitPhysicsUpdate("lockRotationX");
              }),
              _axisLockChip("RY", lockRotationY, () {
                setState(() => lockRotationY = !lockRotationY);
                _emitPhysicsUpdate("lockRotationY");
              }),
              _axisLockChip("RZ", lockRotationZ, () {
                setState(() => lockRotationZ = !lockRotationZ);
                _emitPhysicsUpdate("lockRotationZ");
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Environment
          _label("Environment Forces"),
          _sliderRow("Wind Strength", windStrength, 0.0, 1.0,
                  (v) => setState(() => windStrength = v),
              onChangeEnd: (_) => _emitPhysicsUpdate("windStrength")),
          _sliderRow("Extra Drag", drag, 0.0, 2.0,
                  (v) => setState(() => drag = v),
              onChangeEnd: (_) => _emitPhysicsUpdate("drag")),

          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _resetToDefaults();
                    _emitPhysicsUpdate();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _quickSimulate,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Quick Simulate"),
                  style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers & UI components ----------------

  Widget _label(String txt) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 6),
    child:
    Text(txt, style: AppTextStyles.body().copyWith(color: AppColors.primary)),
  );

  Widget _sliderRow(String label, double value, double min, double max,
      ValueChanged<double> onChanged,
      {ValueChanged<double>? onChangeEnd}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: AppTextStyles.body()),
          const Spacer(),
          Text(
              value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(2),
              style: AppTextStyles.caption(size: 12)),
        ]),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: (v) {
            onChanged(v);
          },
          onChangeEnd: onChangeEnd,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
      ],
    );
  }

  Widget _axisLockChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.6)),
        ),
        child: Text(label,
            style: AppTextStyles.caption()
                .copyWith(color: active ? Colors.black : AppColors.text)),
      ),
    );
  }

  // ---------------- Actions / Presets ----------------

  void _applyPreset(String p) {
    switch (p) {
      case "Static (Fixed)":
        mass = 10000;
        gravityScale = 0.0;
        collisionEnabled = true;
        bounciness = 0;
        friction = 1.0;
        linearDamping = 1.0;
        angularDamping = 1.0;
        lockPositionX = lockPositionY = lockPositionZ = true;
        lockRotationX = lockRotationY = lockRotationZ = true;
        softBody = false;
        break;

      case "Lightweight (Feather)":
        mass = 0.05;
        gravityScale = 0.6;
        bounciness = 0.05;
        friction = 0.1;
        linearDamping = 0.02;
        angularDamping = 0.02;
        lockPositionX = lockPositionY = lockPositionZ = false;
        softBody = false;
        break;

      case "Bouncy (Rubber)":
        mass = 1.2;
        bounciness = 0.9;
        friction = 0.2;
        linearDamping = 0.05;
        angularDamping = 0.05;
        softBody = false;
        break;

      case "Heavy (Iron)":
        mass = 75;
        gravityScale = 1.0;
        bounciness = 0.02;
        friction = 0.9;
        break;

      case "Jelly (SoftBody)":
        softBody = true;
        softness = 0.4;
        structuralStiffness = 0.35;
        mass = 2.0;
        break;

      default:
        _resetToDefaults();
    }

    setState(() {});
    _emitPhysicsUpdate("preset_applied");
  }

  void _resetToDefaults() {
    mass = 1.0;
    gravityScale = 1.0;
    linearDamping = 0.05;
    angularDamping = 0.05;
    collisionShape = "Convex Mesh";
    collisionEnabled = true;
    bounciness = 0.15;
    friction = 0.45;
    softBody = false;
    softness = 0.25;
    structuralStiffness = 0.6;
    lockPositionX = lockPositionY = lockPositionZ = false;
    lockRotationX = lockRotationY = lockRotationZ = false;
    windStrength = 0.0;
    drag = 0.0;
    preset = "Default";
  }

  void _quickSavePreset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Custom physics preset saved (local).")),
    );
  }

  void _quickSimulate() {
    // Local quick feedback — Portal Editor can override by applying physics to runtime.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quick physics simulation triggered (demo).")),
    );
  }
}
