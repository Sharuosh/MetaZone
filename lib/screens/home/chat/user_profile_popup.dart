// lib/screens/home/chat/user_profile_popup.dart
// MetaZone — User Profile Popup (Final Polished Version)

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class UserProfilePopup extends StatelessWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const UserProfilePopup({
    super.key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: AppColors.border.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 22,
                spreadRadius: 3,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ---------------- Avatar ----------------
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: AppColors.neonGradient,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.card,
                  backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Text(
                    userName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 14),

              // ---------------- Name ----------------
              Text(
                userName,
                style: AppTextStyles.title(size: 20),
              ),

              const SizedBox(height: 6),

              Text(
                "@${userName.toLowerCase().replaceAll(' ', '_')}",
                style: AppTextStyles.caption(),
              ),

              const SizedBox(height: 20),

              // ---------------- Top Buttons ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bigAction(
                    Icons.person_rounded, "Profile", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/full_profile",
                        arguments: {"userId": userId});
                  },
                  ),

                  _bigAction(
                    Icons.collections, "Media", () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/shared_media",
                        arguments: {"userId": userId});
                  },
                  ),

                  _bigAction(
                    Icons.chat_bubble_rounded, "Message", () {
                    Navigator.pop(context);
                  },
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Divider(color: AppColors.border.withOpacity(0.45)),
              const SizedBox(height: 12),

              // ---------------- Secondary Actions ----------------
              _secondary(context, Icons.group, "Mutual Spots"),
              _secondary(context, Icons.auto_awesome, "Achievements"),
              _secondary(context, Icons.public, "AR Creations"),
              _secondary(context, Icons.block, "Block User", danger: true),
              _secondary(context, Icons.flag, "Report User", danger: true),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MAIN BUTTON ====================
  Widget _bigAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.neonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySoft.withOpacity(.7),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption(size: 12)),
        ],
      ),
    );
  }

  // ==================== SECONDARY ROW ====================
  Widget _secondary(BuildContext context, IconData icon, String title, {bool danger = false}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: danger ? Colors.redAccent : AppColors.textSoft,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: danger ? Colors.redAccent : AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }
}
