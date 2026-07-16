import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ClearWorldCacheScreen extends StatelessWidget {
  const ClearWorldCacheScreen({super.key});

  void _clear(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("World map cache cleared (demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Clear World Map Cache"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "The AR world-map cache stores surfaces, anchors, and environmental tracking data.\n\n"
                    "Clearing it helps solve AR calibration issues.",
                style: AppTextStyles.body(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _clear(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Clear Cache"),
          ),
        ],
      ),
    );
  }
}
