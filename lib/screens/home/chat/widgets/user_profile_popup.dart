import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../user_profile_screen.dart';
import '../shared_media_screen.dart';

class UserProfilePopup extends StatelessWidget {
  final String username;
  final String userId;

  const UserProfilePopup({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 230,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              username[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(username,
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),

          const SizedBox(height: 18),

          _btn(context, Icons.person, "View Profile", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  username: username,
                  userId: userId,
                ),
              ),
            );
          }),

          _btn(context, Icons.photo_library, "Shared Media", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SharedMediaScreen(
                  username: username,
                  userId: userId,
                ),
              ),
            );
          }),

          _btn(context, Icons.chat, "Start Private Chat", () {
            Navigator.pop(context);
            // Connect into Private Chat later
          }),
        ],
      ),
    );
  }

  Widget _btn(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: TextStyle(color: AppColors.text)),
      onTap: onTap,
    );
  }
}
