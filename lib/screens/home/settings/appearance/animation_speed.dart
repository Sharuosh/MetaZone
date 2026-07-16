import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AnimationSpeedScreen extends StatefulWidget {
  const AnimationSpeedScreen({super.key});

  @override
  State<AnimationSpeedScreen> createState() => _AnimationSpeedScreenState();
}

class _AnimationSpeedScreenState extends State<AnimationSpeedScreen> {
  double _speed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Animation Speed"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("UI Animation Speed", style: AppTextStyles.title()),
            const SizedBox(height: 12),

            Slider(
              value: _speed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: "${_speed.toStringAsFixed(2)}x",
              onChanged: (v) => setState(() => _speed = v),
            ),

            const SizedBox(height: 25),

            Text("Preview", style: AppTextStyles.title()),
            const SizedBox(height: 12),

            AnimatedContainer(
              duration: Duration(milliseconds: (800 ~/ _speed)),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                "Preview Animation",
                style: AppTextStyles.body(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
