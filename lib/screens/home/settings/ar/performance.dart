import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARPerformanceScreen extends StatefulWidget {
  const ARPerformanceScreen({super.key});

  @override
  State<ARPerformanceScreen> createState() => _ARPerformanceScreenState();
}

class _ARPerformanceScreenState extends State<ARPerformanceScreen> {
  String renderQuality = "High";
  double objectQuality = 1.0; // slider 0.25 - 2.0
  bool powerSaving = false;
  bool highPerformance = true;
  bool autoPrefetch = true;
  bool motionPrediction = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR Performance"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text("Render quality"),
            subtitle: Text(renderQuality),
            trailing: DropdownButton<String>(
              value: renderQuality,
              items: const [
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
              ],
              onChanged: (v) => setState(() => renderQuality = v ?? "High"),
            ),
          ),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("High performance mode"),
              subtitle: const Text("Unlock full device AR power"),
              value: highPerformance,
              onChanged: (v) => setState(() => highPerformance = v),
            ),
          ),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Power saving mode"),
              subtitle: const Text("Reduce AR load to save battery"),
              value: powerSaving,
              onChanged: (v) => setState(() => powerSaving = v),
            ),
          ),

          const SizedBox(height: 12),
          Text("Object quality: ${objectQuality.toStringAsFixed(2)}",
              style: AppTextStyles.caption()),
          Slider(
            value: objectQuality,
            min: 0.25,
            max: 2.0,
            divisions: 8,
            onChanged: (v) => setState(() => objectQuality = v),
          ),

          const SizedBox(height: 12),
          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Auto-prefetch AR assets"),
              subtitle: const Text("Load required models before entering scenes"),
              value: autoPrefetch,
              onChanged: (v) => setState(() => autoPrefetch = v),
            ),
          ),

          Card(
            color: AppColors.card,
            child: SwitchListTile(
              title: const Text("Motion prediction"),
              subtitle: const Text("Predict movement for smoother AR"),
              value: motionPrediction,
              onChanged: (v) => setState(() => motionPrediction = v),
            ),
          ),
        ],
      ),
    );
  }
}
