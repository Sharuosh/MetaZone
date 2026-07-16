import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class AREngineInfoScreen extends StatelessWidget {
  const AREngineInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final info = {
      "Engine version": "MetaZone AR Engine 1.3.2",
      "Rendering pipeline": "Neon-PBR Hybrid",
      "Tracking provider": "Advanced SLAM + Predictive Motion",
      "Supported devices": "ARCore, ARKit, Meta Glasses"
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("AR Engine info"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: info.entries.map((e) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              title: Text(e.key),
              subtitle: Text(e.value, style: AppTextStyles.caption()),
            ),
          );
        }).toList(),
      ),
    );
  }
}
