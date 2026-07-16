import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ARPermissionsScreen extends StatefulWidget {
  const ARPermissionsScreen({super.key});

  @override
  State<ARPermissionsScreen> createState() => _ARPermissionsScreenState();
}

class _ARPermissionsScreenState extends State<ARPermissionsScreen> {
  bool camera = true;
  bool location = true;
  bool motion = true;
  bool sensors = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR Permissions"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _switch("Camera", "Required for AR scanning", camera, (v) => setState(() => camera = v)),
          _switch("Location", "Used for geolocation AR spots", location, (v) => setState(() => location = v)),
          _switch("Motion sensors", "Gyro & accelerometer for stability", motion, (v) => setState(() => motion = v)),
          _switch("Device sensors", "Advanced tracking (depth, LiDAR)", sensors, (v) => setState(() => sensors = v)),
        ],
      ),
    );
  }

  Widget _switch(String title, String sub, bool val, Function(bool) on) {
    return Card(
      color: AppColors.card,
      child: SwitchListTile(
        value: val,
        onChanged: on,
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
      ),
    );
  }
}
