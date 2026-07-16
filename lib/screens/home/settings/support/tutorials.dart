import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  final tutorials = const [
    {
      'title': "Getting Started with MetaZone",
      'desc': "Learn the basics of AR objects, zones, and interactions."
    },
    {
      'title': "How AR Tracking Works",
      'desc': "Understanding anchors, meshes, and world mapping."
    },
    {
      'title': "Creating AR Spots",
      'desc': "Step-by-step guide to placing content in real world."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Tutorials & Guides"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: tutorials.length,
        itemBuilder: (_, i) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(Icons.play_circle_fill, color: AppColors.primary),
              title: Text(tutorials[i]['title']!, style: AppTextStyles.body()),
              subtitle: Text(tutorials[i]['desc']!, style: AppTextStyles.caption()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
