import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// --------------------------------------------------------------
///   META ZONE — PROFILE PREVIEW (Followers / Following / Search)
/// --------------------------------------------------------------

class ProfilePreview extends StatelessWidget {
  final String userId;
  final String name;
  final String handle;
  final String bio;
  final bool online;
  final bool mutual;
  final VoidCallback? onOpen;
  final VoidCallback? onAction;

  const ProfilePreview({
    super.key,
    required this.userId,
    required this.name,
    required this.handle,
    required this.bio,
    this.online = false,
    this.mutual = false,
    this.onOpen,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cardSoft,
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(width: 14),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.title(size: 15),
                        ),
                      ),
                      if (mutual)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Mutual",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(handle, style: AppTextStyles.caption()),
                  const SizedBox(height: 6),
                  Text(
                    bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(size: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Action Button
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: mutual ? Colors.transparent : AppColors.primary,
                foregroundColor: mutual ? AppColors.primary : Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                side: mutual
                    ? BorderSide(color: AppColors.primary.withOpacity(.5))
                    : BorderSide.none,
              ),
              child: Text(
                mutual ? "Mutual" : "Follow",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
