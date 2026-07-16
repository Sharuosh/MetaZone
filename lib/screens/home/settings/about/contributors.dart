import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ContributorsScreen extends StatelessWidget {
  const ContributorsScreen({super.key});

  final members = const [
    {"name": "Abdelrahman Sharuosh", "role": "Founder / AR Vision Lead"},
    {"name": "MetaZone Dev Team", "role": "Flutter / AR Integration"},
    {"name": "UX Contributors", "role": "UI / Motion / Neon Design"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Contributors"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: members.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          return ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(.2),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(members[i]["name"]!, style: AppTextStyles.body()),
            subtitle: Text(members[i]["role"]!, style: AppTextStyles.caption()),
          );
        },
      ),
    );
  }
}
