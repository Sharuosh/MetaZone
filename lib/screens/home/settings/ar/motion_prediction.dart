import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MotionPredictionScreen extends StatefulWidget {
  const MotionPredictionScreen({super.key});

  @override
  State<MotionPredictionScreen> createState() => _MotionPredictionScreenState();
}

class _MotionPredictionScreenState extends State<MotionPredictionScreen> {
  double smoothing = 0.5; // Motion Smoothing
  bool predictiveTracking = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Motion Prediction", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            "Optimize how MetaZone predicts real-world movement for AR rendering.",
            style: AppTextStyles.caption(),
          ),

          const SizedBox(height: 20),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Predictive Tracking"),
              subtitle: const Text("Enhance stability by predicting future movement"),
              value: predictiveTracking,
              onChanged: (v) => setState(() => predictiveTracking = v),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: AppColors.card,
            child: Column(
              children: [
                ListTile(
                  title: const Text("Motion Smoothing"),
                  subtitle: Text("${(smoothing * 100).round()}%"),
                ),
                Slider(
                  value: smoothing,
                  min: 0,
                  max: 1,
                  onChanged: (v) => setState(() => smoothing = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
