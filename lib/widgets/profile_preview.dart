import 'package:flutter/material.dart';

import '../core/theme/theme.dart';

/// --------------------------------------------------------------
/// META ZONE — PROFILE PREVIEW
/// --------------------------------------------------------------

class ProfilePreview extends StatelessWidget {
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

  final String userId;
  final String name;
  final String handle;
  final String bio;

  final bool online;
  final bool mutual;

  final VoidCallback? onOpen;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(
                alpha: .10,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.cardSoft,
                  child: Text(
                    name[0].toUpperCase(),
                    style: AppTextStyles.title.copyWith(
                      fontSize: 20,
                      color: AppColors.primary,
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
                        border: Border.all(
                          color: AppColors.card,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style:
                          AppTextStyles.title.copyWith(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (mutual)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(
                              alpha: .12,
                            ),
                            borderRadius:
                            AppRadius.mdRadius,
                          ),
                          child: Text(
                            'Mutual',
                            style:
                            AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color:
                              AppColors.primary,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  Text(
                    handle,
                    style:
                    AppTextStyles.caption.copyWith(
                      color:
                      AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                    AppTextStyles.body.copyWith(
                      fontSize: 12,
                      color:
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: mutual
                    ? Colors.transparent
                    : AppColors.primary,
                foregroundColor: mutual
                    ? AppColors.primary
                    : Colors.black,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                side: mutual
                    ? BorderSide(
                  color: AppColors.primary
                      .withValues(
                    alpha: .50,
                  ),
                )
                    : BorderSide.none,
              ),
              child: Text(
                mutual ? 'Mutual' : 'Follow',
                style:
                AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mutual
                      ? AppColors.primary
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}