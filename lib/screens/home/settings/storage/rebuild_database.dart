import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RebuildDatabaseScreen extends StatelessWidget {
  const RebuildDatabaseScreen({super.key});

  void _rebuild(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Database rebuilt (demo)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Rebuild Database"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "This will:\n"
                    "• Rebuild indexes\n"
                    "• Fix orphaned AR objects\n"
                    "• Remove incomplete sessions\n"
                    "• Optimize storage tables",
                style: AppTextStyles.body(),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => _rebuild(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Rebuild Now"),
          ),
        ],
      ),
    );
  }
}
