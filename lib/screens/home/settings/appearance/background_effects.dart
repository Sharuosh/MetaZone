import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class BackgroundEffectsScreen extends StatefulWidget {
  const BackgroundEffectsScreen({super.key});

  @override
  State<BackgroundEffectsScreen> createState() => _BackgroundEffectsScreenState();
}

class _BackgroundEffectsScreenState extends State<BackgroundEffectsScreen> {
  bool galaxy = true;
  bool particles = true;
  bool fog = false;
  bool animatedBG = true;

  double particleDensity = 0.4;
  double animationSpeed = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Background Effects"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          _switch("Galaxy Background", galaxy, (v) => setState(() => galaxy = v)),
          _switch("Particles", particles, (v) => setState(() => particles = v)),
          _switch("Fog Effect", fog, (v) => setState(() => fog = v)),
          _switch("Animated Background", animatedBG, (v) => setState(() => animatedBG = v)),

          const SizedBox(height: 20),
          _slider("Particle Density", particleDensity,
                  (v) => setState(() => particleDensity = v)),
          _slider("Animation Speed", animationSpeed,
                  (v) => setState(() => animationSpeed = v)),

          const SizedBox(height: 25),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text("Background Preview", style: AppTextStyles.heading()),
          )
        ],
      ),
    );
  }

  Widget _switch(String title, bool val, Function(bool) onChanged) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(title),
        value: val,
        onChanged: onChanged,
      ),
    );
  }

  Widget _slider(String label, double val, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        Slider(
          value: val,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
