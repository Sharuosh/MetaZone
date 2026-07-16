import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

import 'contributors.dart';
import 'tech_stack.dart';
import 'version_notes.dart';
import 'build_number.dart';
import 'meta_integration.dart';

class AboutMainScreen extends StatelessWidget {
  const AboutMainScreen({super.key});

  Widget _item(BuildContext c, IconData icon, String title, String sub, Widget page) {
    return Card(
      color: AppColors.card,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.body()),
        subtitle: Text(sub, style: AppTextStyles.caption()),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("About MetaZone"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text("MetaZone", style: AppTextStyles.title(size: 22)),
          const SizedBox(height: 6),

          Text("Version 1.0.0 • Build 43",
              style: AppTextStyles.caption()),

          const SizedBox(height: 6),
          Text(
            "© $year MetaZone. All rights reserved.",
            style: AppTextStyles.body(),
          ),

          const SizedBox(height: 20),

          _item(
            context,
            Icons.people,
            "Contributors",
            "Team members & creators",
            const ContributorsScreen(),
          ),

          _item(
            context,
            Icons.build,
            "Technology Stack",
            "Frameworks, architecture, AR engines",
            const TechStackScreen(),
          ),

          _item(
            context,
            Icons.article,
            "Version Notes",
            "Updates & change logs",
            const VersionNotesScreen(),
          ),

          _item(
            context,
            Icons.confirmation_number_outlined,
            "Build Number",
            "Internal build & release information",
            const BuildNumberScreen(),
          ),

          _item(
            context,
            Icons.vrpano_outlined,
            "Meta Integration",
            "Future support for Meta AR Glasses",
            const MetaIntegrationScreen(),
          ),
        ],
      ),
    );
  }
}
