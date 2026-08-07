import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

class MetaAvatar extends StatelessWidget {
  const MetaAvatar({
    super.key,
    this.image,
    this.initials,
    this.size = 52,
    this.onTap,
    this.border = true,
    this.heroTag,
  });

  final ImageProvider? image;

  final String? initials;

  final double size;

  final bool border;

  final VoidCallback? onTap;

  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget avatar = Hero(
      tag: heroTag ?? hashCode,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: border
              ? Border.all(
            color: AppColors.glassBorder,
          )
              : null,
          boxShadow: AppShadows.glass,
          image: image != null
              ? DecorationImage(
            image: image!,
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: image == null
            ? Center(
          child: Text(
            initials ?? '',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: size * .34,
            ),
          ),
        )
            : null,
      ),
    );

    if (onTap == null) return avatar;

    return InkWell(
      borderRadius: AppRadius.circleRadius,
      onTap: onTap,
      child: avatar,
    );
  }
}