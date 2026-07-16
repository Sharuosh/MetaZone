import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TechStackScreen extends StatelessWidget {
  const TechStackScreen({super.key});

  final stack = const [
    {"title": "Flutter", "sub": "UI, animations, cross-platform foundations"},
    {"title": "Unity AR Foundation", "sub": "AR engine, tracking, rendering"},
    {"title": "Firebase", "sub": "Auth, database, storage, cloud functions"},
    {"title": "Google ML Kit", "sub": "Future hand tracking & plane classification"},
    {"title": "Custom AR Engine", "sub": "Optimized for MetaZone performance"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Technology Stack"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: stack.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.layers, color: AppColors.primary),
              title: Text(stack[i]['title']!, style: AppTextStyles.body()),
              subtitle: Text(stack[i]['sub']!, style: AppTextStyles.caption()),
            ),
          );
        },
      ),
    );
  }
}
