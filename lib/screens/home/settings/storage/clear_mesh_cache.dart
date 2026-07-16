import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ClearMeshCacheScreen extends StatelessWidget {
  const ClearMeshCacheScreen({super.key});

  void _clear(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mesh cache cleared (demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Clear Mesh Cache"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Mesh cache includes saved plane detection meshes, point clouds, and AR surface geometry.\n\n"
                    "Clearing it may improve performance on older devices.",
                style: AppTextStyles.body(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _clear(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Clear Mesh Cache"),
          ),
        ],
      ),
    );
  }
}
