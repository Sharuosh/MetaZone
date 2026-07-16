// File: lib/screens/ar/object_editor/panels/transform_panel.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TransformPanel extends StatefulWidget {
  final Function(String axis, double value)? onPositionChanged;
  final Function(String axis, double value)? onRotationChanged;
  final Function(String axis, double value)? onScaleChanged;

  const TransformPanel({
    super.key,
    this.onPositionChanged,
    this.onRotationChanged,
    this.onScaleChanged,
  });

  @override
  State<TransformPanel> createState() => _TransformPanelState();
}

class _TransformPanelState extends State<TransformPanel> {
  bool uniformScale = true;

  // Position / Rotation / Scale values
  final Map<String, double> pos = {"x": 0, "functions.mz": 0, "z": 0};
  final Map<String, double> rot = {"x": 0, "functions.mz": 0, "z": 0};
  final Map<String, double> scale = {"x": 1, "functions.mz": 1, "z": 1};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Position"),
          _axisSliders(pos, widget.onPositionChanged, -5, 5),

          const SizedBox(height: 16),
          _sectionTitle("Rotation"),
          _axisSliders(rot, widget.onRotationChanged, -180, 180, isRotation: true),

          const SizedBox(height: 16),
          _sectionTitle("Scale"),
          _scaleHeader(),
          _axisSliders(scale, widget.onScaleChanged, 0.1, 5),
        ],
      ),
    );
  }

  // ======================================================
  // SECTION TITLE
  // ======================================================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.title(size: 16),
      ),
    );
  }

  // ======================================================
  // AXIS SLIDERS (X / Y / Z)
  // ======================================================
  Widget _axisSliders(
      Map<String, double> data,
      Function(String axis, double value)? callback,
      double min,
      double max,
      {bool isRotation = false}) {
    return Column(
      children: data.keys.map((axis) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(axis.toUpperCase(),
                    style: AppTextStyles.caption()),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Slider(
                  value: data[axis]!,
                  min: min,
                  max: max,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() {
                      data[axis] = v;

                      if (callback != null) callback(axis, v);

                      if (!isRotation && data == scale && uniformScale) {
                        data.forEach((k, _) => data[k] = v);
                      }
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              _resetButton(() {
                setState(() {
                  data[axis] = isRotation ? 0 : (data == scale ? 1 : 0);
                });
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ======================================================
  // SCALE — UNIFORM TOGGLE
  // ======================================================
  Widget _scaleHeader() {
    return Row(
      children: [
        Text("Scale Controls", style: AppTextStyles.body()),
        const Spacer(),
        Switch(
          value: uniformScale,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => uniformScale = v),
        ),
        Text("Uniform", style: AppTextStyles.caption()),
      ],
    );
  }

  // ======================================================
  // RESET BUTTON
  // ======================================================
  Widget _resetButton(VoidCallback reset) {
    return GestureDetector(
      onTap: reset,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.restart_alt, size: 20, color: Colors.white70),
      ),
    );
  }
}
