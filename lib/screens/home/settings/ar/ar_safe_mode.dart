import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARSafeModeScreen extends StatefulWidget {
  const ARSafeModeScreen({super.key});

  @override
  State<ARSafeModeScreen> createState() => _ARSafeModeScreenState();
}

class _ARSafeModeScreenState extends State<ARSafeModeScreen> {
  bool safeMode = false;
  bool autoLimitEffects = true;
  bool reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("AR Safe Mode", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            "Activate Safe Mode to reduce AR intensity for users sensitive to motion or brightness.",
            style: AppTextStyles.caption(),
          ),

          const SizedBox(height: 20),

          _toggle(
            "Enable Safe Mode",
            "Reduces effects, brightness & camera-icon motion",
            safeMode,
                (v) => setState(() => safeMode = v),
          ),

          _toggle(
            "Auto-limit heavy effects",
            "Disable neon bursts & particle storms",
            autoLimitEffects,
                (v) => setState(() => autoLimitEffects = v),
          ),

          _toggle(
            "Reduce motion",
            "Smoother camera-icon transitions for comfort",
            reduceMotion,
                (v) => setState(() => reduceMotion = v),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String t, String s, bool value, Function(bool) onChanged) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        title: Text(t),
        subtitle: Text(s),
        value: value,
        onChanged: (v) => onChanged(v),
      ),
    );
  }
}
