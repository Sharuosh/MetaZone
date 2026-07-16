import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../ar/global_search/search_screen.dart';
import '../notifications/notifications_screen.dart'; // لو عندك شاشة إشعارات

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = "Abdelrahman";

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.card,
          child: Text(
            userName[0],
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Welcome, $userName",
            style: AppTextStyles.title(size: 16),
          ),
        ),

        // Search -> يفتح SearchScreen
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GlobalSearchScreen()),
            );
          },
          icon: Icon(Icons.search, color: AppColors.textSoft),
        ),

        // Notifications -> يفتح شاشة الاشعارات (إن لم تكن موجودة، عدّل إلى صفحة مناسبة)
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          icon: Icon(Icons.notifications_active_outlined, color: AppColors.primary),
        ),
      ],
    );
  }
}
