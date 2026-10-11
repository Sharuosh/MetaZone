import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

class NearbyPlaceCard extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback? onTap;

  const NearbyPlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: place.name,
      child: SizedBox(
        width: 268,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: AppColors.primary.withValues(
              alpha: 0.06,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.textSoft.withValues(
                    alpha: 0.08,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.055,
                    ),
                    blurRadius: 18,
                    spreadRadius: 0,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildImage(),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 136,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(
                      alpha: 0.02,
                    ),
                    Colors.black.withValues(
                      alpha: 0.28,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: _buildZoneBadge(),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: _buildOpenBadge(),
          ),

          Positioned(
            left: 12,
            bottom: 10,
            child: _buildDistanceBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    final String imageUrl = place.imageUrl.trim();

    if (imageUrl.isEmpty) {
      return _buildImageFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) {
        return _buildImageFallback();
      },
      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildImageFallback(),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(
              alpha: 0.78,
            ),
            AppColors.secondary.withValues(
              alpha: 0.72,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.place_rounded,
          size: 42,
          color: Colors.white.withValues(
            alpha: 0.90,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        11,
        14,
        13,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body(
                    size: 15,
                    color: AppColors.text,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              if (place.hasRating)
                _buildRating(),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            place.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmallStyle(
              size: 12,
              color: AppColors.textSoft,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.textSoft,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  place.distance,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(
                    size: 11,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
              if (place.hasReviews) ...[
                const SizedBox(width: 8),
                _buildReviewsCount(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          color: Colors.amber,
          size: 16,
        ),
        const SizedBox(width: 2),
        Text(
          place.rating.toStringAsFixed(1),
          style: AppTextStyles.caption(
            size: 11,
            color: AppColors.text,
          ).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsCount() {
    return Text(
      '${place.reviewCount} reviews',
      style: AppTextStyles.caption(
        size: 10,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildZoneBadge() {
    final String status = place.zoneStatus.trim();

    if (status.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.28,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.20,
          ),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _zoneStatusColor(status),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              size: 9,
              color: Colors.white,
            ).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenBadge() {
    final bool isOpen = place.isOpen;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.28,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.18,
          ),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen
                  ? Colors.greenAccent
                  : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: AppTextStyles.caption(
              size: 9,
              color: Colors.white,
            ).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceBadge() {
    if (place.distance.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.30,
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.near_me_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            place.distance,
            style: AppTextStyles.caption(
              size: 9,
              color: Colors.white,
            ).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _zoneStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'smart':
        return Colors.cyanAccent;

      case 'active':
        return Colors.greenAccent;

      case 'basic':
        return Colors.white70;

      default:
        return Colors.white70;
    }
  }
}