import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class UIDepthScreen extends StatefulWidget {
  const UIDepthScreen({super.key});

  @override
  State<UIDepthScreen> createState() => _UIDepthScreenState();
}

class _UIDepthScreenState extends State<UIDepthScreen> {
  double shadowDepth = 0.5;
  double parallax = 0.3;
  bool enable3D = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("UI Depth"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              value: enable3D,
              onChanged: (v) => setState(() => enable3D = v),
              title: const Text("Enable 3D Interface"),
              subtitle: const Text("Adds layers, motion and shadows"),
            ),
          ),

          _slider("Shadow depth", shadowDepth, (v) => setState(() => shadowDepth = v)),
          _slider("Parallax movement", parallax, (v) => setState(() => parallax = v)),

          const SizedBox(height: 30),
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.4),
                  blurRadius: shadowDepth * 30,
                  spreadRadius: shadowDepth * 10,
                  offset: Offset(0, shadowDepth * 20),
                ),
              ],
            ),
            child: Text("UI Depth Preview", style: AppTextStyles.heading()),
          )
        ],
      ),
    );
  }

  Widget _slider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        Slider(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
