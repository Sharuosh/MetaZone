import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class NeonSettingsScreen extends StatefulWidget {
  const NeonSettingsScreen({super.key});

  @override
  State<NeonSettingsScreen> createState() => _NeonSettingsScreenState();
}

class _NeonSettingsScreenState extends State<NeonSettingsScreen> {
  double intensity = 0.6;
  double glow = 0.5;
  Color neonColor = Colors.cyanAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Neon Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          _slider("Intensity", intensity, (v) => setState(() => intensity = v)),
          _slider("Glow", glow, (v) => setState(() => glow = v)),

          const SizedBox(height: 20),
          Text("Neon Color", style: AppTextStyles.title()),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            children: [
              _color(Colors.cyanAccent),
              _color(Colors.pinkAccent),
              _color(Colors.blueAccent),
              _color(Colors.purpleAccent),
              _color(Colors.greenAccent),
            ],
          ),

          const SizedBox(height: 30),

          Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: neonColor.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: neonColor.withOpacity(.7),
                  blurRadius: glow * 30,
                  spreadRadius: intensity * 10,
                )
              ],
            ),
            child: Text("Preview", style: AppTextStyles.heading()),
          ),
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

  Widget _color(Color c) {
    return GestureDetector(
      onTap: () => setState(() => neonColor = c),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: c,
      ),
    );
  }
}
