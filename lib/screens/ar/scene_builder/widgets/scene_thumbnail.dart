// File: lib/screens/ar/scene_builder/widgets/scene_thumbnail.dart
// MetaZone – Scene Thumbnail Widget (Ultra PRO 2025)
// Reusable thumbnail for scenes, portals, saved projects & previews.

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class SceneThumbnail extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double height;
  final VoidCallback? onTap;
  final Widget? overlayIcon;

  const SceneThumbnail({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.height = 140,
    this.onTap,
    this.overlayIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(.32)),
          color: AppColors.card.withOpacity(.25),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // BACKGROUND IMAGE OR PLACEHOLDER
              Positioned.fill(
                child: imageUrl != null
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.black38,
                  child: Center(
                    child: Icon(Icons.photo, color: Colors.white24, size: 40),
                  ),
                ),
              ),

              // GRADIENT OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(.55),
                        Colors.black.withOpacity(.15),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // TITLE + SUBTITLE
              Positioned(
                left: 14,
                right: 14,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title(size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption(size: 11)
                            .copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
                  ],
                ),
              ),

              // OPTIONAL OVERLAY ICON (Top-right)
              if (overlayIcon != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: overlayIcon!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
