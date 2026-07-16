import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  final contacts = const [
    {"icon": Icons.email, "title": "Email Support", "value": "support@metazone.app"},
    {"icon": Icons.discord, "title": "Discord Community", "value": "discord.gg/metazone"},
    {"icon": Icons.alternate_email, "title": "X (Twitter)", "value": "@MetaZoneAR"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text("Contact Support"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          return Card(
            color: AppColors.card,
            child: ListTile(
              leading: Icon(contacts[i]['icon'] as IconData, color: AppColors.primary),
              title: Text(contacts[i]['title'] as String),
              subtitle: Text(contacts[i]['value'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${contacts[i]['title']} (demo)")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
