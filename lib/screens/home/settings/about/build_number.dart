import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class BuildNumberScreen extends StatelessWidget {
  const BuildNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Build Information", style: AppTextStyles.heading()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "MetaZone Build Details",
              style: AppTextStyles.title(size: 20),
            ),
            const SizedBox(height: 12),

            _info("App Version", "1.0.0"),
            _info("Build Number", "43"),
            _info("Release Channel", "Stable"),
            _info("Compiled On", "Flutter 3.19 • Dart 3.3"),

            const SizedBox(height: 20),
            Divider(color: AppColors.border),

            const SizedBox(height: 12),
            Text(
              "This build is optimized for:",
              style: AppTextStyles.body(), // ← تم التعديل
            ),
            const SizedBox(height: 10),

            _bullet("High-accuracy AR tracking"),
            _bullet("Stable rendering performance"),
            _bullet("Meta glasses compatibility (future)"),
            _bullet("Neon & 3D UI visual layers"),
            _bullet("Low-latency networking"),

            const Spacer(),

            Center(
              child: Text(
                "© ${DateTime.now().year} MetaZone",
                style: AppTextStyles.caption(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.body()),
          Text(value, style: AppTextStyles.caption()), // ← تم التعديل
        ],
      ),
    );
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
