// File: cover_picker.dart
// MetaZone — Scene Builder: Cover Picker (2025 • FIXED FOR PublishSceneScreen)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class CoverPicker extends StatelessWidget {
  final String? imageUrl;
  final Function(String url) onPicked;
  final VoidCallback? onRemove;
  final double height;

  const CoverPicker({
    super.key,
    required this.onPicked,
    this.imageUrl,
    this.onRemove,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // هنا المفروض تفتح File Picker أو Image Picker
        // حالياً placeholder لحد ما نضيف picker حقيقي
        onPicked("https://picsum.photos/seed/cover/800/500");
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Thumbnail or Placeholder
              Positioned.fill(
                child: imageUrl == null
                    ? Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.card,
                        AppColors.surface.withOpacity(.5),
                      ],
                    ),
                  ),
                  child: Text(
                    "Tap to Upload Cover",
                    style: AppTextStyles.caption()
                        .copyWith(color: AppColors.textSoft),
                  ),
                )
                    : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Remove button
              if (imageUrl != null && onRemove != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Text
              Positioned(
                bottom: 12,
                left: 12,
                child: Text(
                  "Recommended: 1280×720",
                  style: AppTextStyles.caption(size: 11)
                      .copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
