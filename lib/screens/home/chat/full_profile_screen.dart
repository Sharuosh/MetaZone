import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class FullProfileScreen extends StatelessWidget {
  final String userId;
  final String username;

  const FullProfileScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(username,
            style: TextStyle(color: AppColors.primary)),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: AppColors.cardSoft,
              child: Text(
                username[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
          Center(
            child: Text(
              "@${username.toLowerCase().replaceAll(" ", "_")}",
              style: TextStyle(color: AppColors.textSoft),
            ),
          ),

          const SizedBox(height: 24),

          _section("Bio"),
          _box(Text(
            "AR explorer & MetaZone early adopter 🚀✨",
            style: TextStyle(color: AppColors.textLight),
          )),

          _section("Achievements"),
          _box(Column(
            children: [
              _achievement("AR Pioneer", Icons.workspace_premium),
              _achievement("Top 1% Explorer", Icons.star_rate_rounded),
            ],
          )),

          _section("Shared Media"),
          _box(Row(
            children: [
              _mediaPreview(),
              const SizedBox(width: 10),
              _mediaPreview(),
              const SizedBox(width: 10),
              _mediaPreview(),
            ],
          )),

          _section("Actions"),
          _box(Column(
            children: [
              _action(Icons.chat, "Send Message"),
              _action(Icons.image, "Shared Media"),
              _action(Icons.block, "Block User", danger: true),
              _action(Icons.flag, "Report User", danger: true),
            ],
          )),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 14),
    child: Text(
      t,
      style: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    ),
  );

  Widget _box(Widget c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: c,
    );
  }

  Widget _achievement(String t, IconData i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(i, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(t, style: TextStyle(color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _mediaPreview() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.image, color: AppColors.primary),
    );
  }

  Widget _action(IconData i, String t, {bool danger = false}) {
    return ListTile(
      leading: Icon(i, color: danger ? Colors.redAccent : AppColors.primary),
      title: Text(
        t,
        style: TextStyle(
          color: danger ? Colors.redAccent : AppColors.text,
        ),
      ),
      trailing:
      Icon(Icons.arrow_forward_ios, color: AppColors.textSoft, size: 14),
    );
  }
}
