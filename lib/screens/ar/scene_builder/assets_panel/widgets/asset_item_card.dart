// File: asset_item_card.dart
// MetaZone – Asset Item Card (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class AssetItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String type;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const AssetItemCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(.3)),
        ),
        child: Column(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.title(size: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(type,
                        style: AppTextStyles.caption(size: 11)
                            .copyWith(color: AppColors.textSoft)),
                    const Spacer(),

                    // Add button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppColors.neonGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, size: 14, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
