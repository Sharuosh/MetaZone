// File: lib/screens/ar/portal_editor/panels/transform_panel.dart
// MetaZone – Transform Panel (Portal-Compatible PRO Edition)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class TransformPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const TransformPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<TransformPanel> createState() => _TransformPanelState();
}

class _TransformPanelState extends State<TransformPanel> {
  double posX = 0, posY = 0, posZ = 0;
  double rotX = 0, rotY = 0, rotZ = 0;
  double scale = 1.0;

  bool precisionMode = false;
  double get step => precisionMode ? 0.01 : 0.1;

  @override
  void initState() {
    super.initState();

    final t = widget.config.transform ?? {};

    posX = (t["posX"] ?? 0).toDouble();
    posY = (t["posY"] ?? 0).toDouble();
    posZ = (t["posZ"] ?? 0).toDouble();
    rotX = (t["rotX"] ?? 0).toDouble();
    rotY = (t["rotY"] ?? 0).toDouble();
    rotZ = (t["rotZ"] ?? 0).toDouble();
    scale = (t["scale"] ?? 1.0).toDouble();
  }

  // ------------------------------------------------------------
  // Emit new config
  // ------------------------------------------------------------
  void _emit() {
    final newTransform = {
      "posX": posX,
      "posY": posY,
      "posZ": posZ,
      "rotX": rotX,
      "rotY": rotY,
      "rotZ": rotZ,
      "scale": scale,
    };

    widget.onChanged(
      widget.config.copyWith(transform: newTransform),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Transform"),

          const SizedBox(height: 18),

          _subTitle("Position"),
          _axisRow("X", posX, (v) {
            setState(() => posX = v);
            _emit();
          }),
          _axisRow("Y", posY, (v) {
            setState(() => posY = v);
            _emit();
          }),
          _axisRow("Z", posZ, (v) {
            setState(() => posZ = v);
            _emit();
          }),

          const SizedBox(height: 18),

          _subTitle("Rotation"),
          _axisRow("X°", rotX, (v) {
            setState(() => rotX = v);
            _emit();
          }, max: 360),
          _axisRow("Y°", rotY, (v) {
            setState(() => rotY = v);
            _emit();
          }, max: 360),
          _axisRow("Z°", rotZ, (v) {
            setState(() => rotZ = v);
            _emit();
          }, max: 360),

          const SizedBox(height: 18),

          _subTitle("Scale"),
          _scaleSlider(),

          const SizedBox(height: 16),

          _precisionToggle(),

          const SizedBox(height: 20),

          _resetButton(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UI Builders
  // ------------------------------------------------------------
  Widget _axisRow(String label, double value, Function(double) onChanged,
      {double max = 5}) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.body()),
            const Spacer(),
            Text(value.toStringAsFixed(2),
                style: AppTextStyles.caption(size: 12)),
          ],
        ),
        Slider(
          value: value,
          min: -max,
          max: max,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _scaleSlider() {
    return Column(
      children: [
        Slider(
          value: scale,
          min: 0.1,
          max: 3.0,
          onChanged: (v) {
            setState(() => scale = v);
            _emit();
          },
          activeColor: AppColors.primary,
          inactiveColor: Colors.white24,
        ),
        Center(
          child: Text("Scale: ${scale.toStringAsFixed(2)}x",
              style: AppTextStyles.caption(size: 12)),
        ),
      ],
    );
  }

  Widget _precisionToggle() {
    return Row(
      children: [
        Switch(
          value: precisionMode,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => precisionMode = v),
        ),
        const SizedBox(width: 8),
        Text("Precision Mode (0.01 step)",
            style: AppTextStyles.caption(size: 12)),
      ],
    );
  }

  Widget _resetButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          posX = posY = posZ = 0;
          rotX = rotY = rotZ = 0;
          scale = 1.0;
        });
        _emit();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surface.withOpacity(.4),
          border: Border.all(color: AppColors.border.withOpacity(.3)),
        ),
        child: Center(
          child: Text("Reset Transform", style: AppTextStyles.body()),
        ),
      ),
    );
  }

  Widget _title(String t) => Text(
    t,
    style: AppTextStyles.title(size: 18),
  );

  Widget _subTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      t,
      style:
      AppTextStyles.title(size: 14).copyWith(color: AppColors.primary),
    ),
  );
}
