import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class MetaIntegrationScreen extends StatelessWidget {
  const MetaIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Meta Integration", style: AppTextStyles.heading()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Meta AR Glasses Integration",
            style: AppTextStyles.title(size: 20),
          ),
          const SizedBox(height: 10),

          Text(
            "MetaZone is designed for future compatibility with Meta AR Glasses. "
                "This includes synchronized world anchors, holographic UI layers, gesture control, "
                "and cross-device AR continuity.",
            style: AppTextStyles.body(),
          ),

          const SizedBox(height: 20),
          Divider(color: AppColors.border),
          const SizedBox(height: 20),

          _sectionTitle("Planned Features"),
          _bullet("Real-world holograms synced with phone AR"),
          _bullet("Hand-tracking compatibility"),
          _bullet("Spatial anchors shared across devices"),
          _bullet("Holographic notifications"),
          _bullet("Meta gestures for AR object control"),

          const SizedBox(height: 20),
          _sectionTitle("Supported Meta Hardware"),
          _bullet("Meta Quest 3 (partial support)"),
          _bullet("Meta Quest Pro"),
          _bullet("Meta AR Glasses (future release)"),

          const SizedBox(height: 20),
          _sectionTitle("Why this matters"),
          _bullet("Use MetaZone in full 3D holographic space"),
          _bullet("Persistent AR objects synced across devices"),
          _bullet("Shared AR experiences with other Meta users"),

          const SizedBox(height: 30),
          Center(
            child: Text(
              "Future-Ready • Holographic • Cross-Device",
              style: AppTextStyles.caption(), // ✅ تم تصحيح المشكلة
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTextStyles.title(size: 16));
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.caption())),
        ],
      ),
    );
  }
}
