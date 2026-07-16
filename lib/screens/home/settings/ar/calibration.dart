import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARCalibrationScreen extends StatefulWidget {
  const ARCalibrationScreen({super.key});

  @override
  State<ARCalibrationScreen> createState() => _ARCalibrationScreenState();
}

class _ARCalibrationScreenState extends State<ARCalibrationScreen> {
  double alignment = 0.0;
  double planeSensitivity = 0.5;

  void _calibrate() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Calibrating..."),
        content: const Text("Follow instructions in the AR view."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void _reset() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Tracking reset (demo)")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR Calibration"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text("Alignment offset"),
            subtitle: Text("Current: ${alignment.toStringAsFixed(2)}"),
          ),
          Slider(
            value: alignment,
            min: -1,
            max: 1,
            divisions: 20,
            onChanged: (v) => setState(() => alignment = v),
          ),

          const SizedBox(height: 12),
          Text("Plane detection sensitivity",
              style: AppTextStyles.caption()),
          Slider(
            value: planeSensitivity,
            min: 0,
            max: 1,
            divisions: 10,
            onChanged: (v) => setState(() => planeSensitivity = v),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _calibrate,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Start calibration"),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _reset,
            child: const Text("Reset tracking"),
          ),
        ],
      ),
    );
  }
}
