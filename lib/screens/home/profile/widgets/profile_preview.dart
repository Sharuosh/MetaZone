import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ProfilePreview extends StatelessWidget {
  final String name;
  final String username;
  final String bio;
  final bool isOnline;
  final int mutual;
  final bool isFollowing;
  final VoidCallback onOpenProfile;
  final VoidCallback onFollow;

  const ProfilePreview({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
    required this.isOnline,
    required this.mutual,
    required this.isFollowing,
    required this.onOpenProfile,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final String avatarLetter =
    name.isNotEmpty ? name[0].toUpperCase() : "?";

    return InkWell(
      onTap: onOpenProfile,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // ================= AVATAR =================
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withOpacity(.12),
                  child: Text(
                    avatarLetter,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // ONLINE INDICATOR
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.card,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // ================= TEXT CONTENT =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.title(size: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "@$username",
                    style: AppTextStyles.caption(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bio,
                    style: AppTextStyles.body(size: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (mutual > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "$mutual mutual connections",
                        style: AppTextStyles.caption(size: 10),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ================= FOLLOW BUTTON =================
            ElevatedButton(
              onPressed: onFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isFollowing ? AppColors.card : AppColors.primary,
                foregroundColor:
                isFollowing ? AppColors.text : Colors.black,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isFollowing
                      ? BorderSide(color: AppColors.border)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                isFollowing ? "Following" : "Follow",
                style: AppTextStyles.caption(size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
