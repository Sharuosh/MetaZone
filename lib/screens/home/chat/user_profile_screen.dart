import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'shared_media_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String username;
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(username, style: TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primarySoft,
              child: Text(username[0].toUpperCase(),
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
              child: Text(username,
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w600))),
          const SizedBox(height: 24),

          _tile(Icons.photo_library, "Shared Media", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SharedMediaScreen(username: username, userId: userId),
              ),
            );
          }),

          _tile(Icons.info, "About", () {}),

          _tile(Icons.person_add, "Add Friend", () {}),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title:
        Text(title, style: TextStyle(color: AppColors.text)),
        onTap: onTap,
      ),
    );
  }
}
