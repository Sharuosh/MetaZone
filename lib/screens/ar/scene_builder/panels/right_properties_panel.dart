// File: lib/screens/ar/scene_builder/panels/right_properties_panel.dart
// MetaZone – AR Scene Builder: Properties Panel (Design Only – Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RightPropertiesPanel extends StatefulWidget {
  const RightPropertiesPanel({super.key});

  @override
  State<RightPropertiesPanel> createState() => _RightPropertiesPanelState();
}

class _RightPropertiesPanelState extends State<RightPropertiesPanel>
    with TickerProviderStateMixin {

  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _sectionTitle("Transform"),
          _transformFields(),
          _divider(),

          _sectionTitle("Material"),
          _materialSection(),
          _divider(),

          _sectionTitle("Lighting"),
          _lightingSection(),
          _divider(),

          _sectionTitle("Physics"),
          _physicsSection(),
          _divider(),

          _sectionTitle("Animation"),
          _animationSection(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // =============================================================
  // SECTION TITLE
  // =============================================================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.title(size: 15),
      ),
    );
  }

  // =============================================================
  // DIVIDER
  // =============================================================
  Widget _divider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 14),
      color: AppColors.border.withOpacity(.25),
    );
  }

  // =============================================================
  // TRANSFORM SECTION
  // =============================================================
  Widget _transformFields() {
    return Column(
      children: [
        _transformRow("Position"),
        const SizedBox(height: 8),
        _transformRow("Rotation"),
        const SizedBox(height: 8),
        _transformRow("Scale"),
      ],
    );
  }

  Widget _transformRow(String label) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: AppTextStyles.caption(size: 12)),
        ),
        Expanded(child: _numberField("X")),
        const SizedBox(width: 6),
        Expanded(child: _numberField("Y")),
        const SizedBox(width: 6),
        Expanded(child: _numberField("Z")),
      ],
    );
  }

  Widget _numberField(String hint) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: TextField(
        style: AppTextStyles.body(size: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          AppTextStyles.caption(size: 11).copyWith(color: AppColors.textSoft),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // =============================================================
  // MATERIAL SECTION
  // =============================================================
  Widget _materialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Base Color"),
        _colorPicker(),
        const SizedBox(height: 10),

        _label("Metallic"),
        _slider(),

        _label("Roughness"),
        _slider(),

        _label("Opacity"),
        _slider(),

        _label("Emission Color"),
        _colorPicker(),

        _label("Emission Power"),
        _slider(),
      ],
    );
  }

  Widget _label(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Text(t, style: AppTextStyles.caption(size: 12)),
    );
  }

  Widget _colorPicker() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface.withOpacity(.15),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Text("Pick Color", style: AppTextStyles.body()),
          const Spacer(),
          Icon(Icons.color_lens, size: 20, color: AppColors.textSoft),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _slider() {
    return SliderTheme(
      data: SliderThemeData(
        thumbColor: AppColors.primary,
        activeTrackColor: AppColors.primarySoft,
        inactiveTrackColor: Colors.white12,
      ),
      child: Slider(
        value: 0.5,
        onChanged: (_) {},
      ),
    );
  }

  // =============================================================
  // LIGHTING SECTION
  // =============================================================
  Widget _lightingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Light Intensity"),
        _slider(),

        _label("Shadow Strength"),
        _slider(),

        Row(
          children: [
            Text("Cast Shadow", style: AppTextStyles.body(size: 13)),
            const Spacer(),
            Switch(
              value: true,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // PHYSICS SECTION
  // =============================================================
  Widget _physicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Enable Physics"),
        Switch(
          value: true,
          activeColor: AppColors.primary,
          onChanged: (_) {},
        ),

        _label("Mass"),
        _slider(),

        _label("Bounciness"),
        _slider(),

        Row(
          children: [
            Text("Gravity", style: AppTextStyles.body(size: 13)),
            const Spacer(),
            Switch(
              value: true,
              activeColor: AppColors.primary,
              onChanged: (_) {},
            ),
          ],
        ),
      ],
    );
  }

  // =============================================================
  // ANIMATION SECTION
  // =============================================================
  Widget _animationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Animation Speed"),
        _slider(),

        Row(
          children: [
            Text("Loop Animation", style: AppTextStyles.body(size: 13)),
            const Spacer(),
            Switch(
              value: false,
              activeColor: AppColors.primary,
              onChanged: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}
