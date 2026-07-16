import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class HandTrackingScreen extends StatefulWidget {
  const HandTrackingScreen({super.key});

  @override
  State<HandTrackingScreen> createState() => _HandTrackingScreenState();
}

class _HandTrackingScreenState extends State<HandTrackingScreen> {
  double sensitivity = 0.5;
  bool enableGestures = true;
  bool safeMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Hand Tracking"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            "Tracking sensitivity (${(sensitivity * 100).toInt()}%)",
            style: AppTextStyles.caption(),
          ),

          Slider(
            value: sensitivity,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => sensitivity = v),
          ),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Enable gestures"),
              subtitle: const Text("Pinch, grab & tap interactions"),
              value: enableGestures,
              onChanged: (v) => setState(() => enableGestures = v),
            ),
          ),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("AR Safe Mode"),
              subtitle: const Text("Reduce complexity for unstable environments"),
              value: safeMode,
              onChanged: (v) => setState(() => safeMode = v),
            ),
          ),
        ],
      ),
    );
  }
}
