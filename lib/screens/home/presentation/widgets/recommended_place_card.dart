import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

class RecommendedPlaceCard extends StatelessWidget {
  final NearbyPlace place;
  final VoidCallback? onTap;

  const RecommendedPlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Recommended place: ${place.name}',
      child: SizedBox(
        width: 250,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            splashColor: AppColors.primary.withValues(
              alpha: 0.06,
            ),
            highlightColor: AppColors.primary.withValues(
              alpha: 0.03,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.textSoft.withValues(
                    alpha: 0.08,
                  ),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.045,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                    child: _buildDetails(),
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
      height: 116,
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
                      alpha: 0.01,
                    ),
                    Colors.black.withValues(
                      alpha: 0.26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 11,
            child: _buildRecommendationBadge(),
          ),
          Positioned(
            left: 11,
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
      return _buildFallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) {
        return _buildFallback();
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
            _buildFallback(),
            const Center(
              child: SizedBox(
                width: 21,
                height: 21,
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

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(
              alpha: 0.80,
            ),
            AppColors.secondary.withValues(
              alpha: 0.76,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 40,
          color: Colors.white.withValues(
            alpha: 0.92,
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
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
            crossAxisAlignment:
            CrossAxisAlignment.center,
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
              if (place.hasRating) _buildRating(),
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
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        place.distance,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: AppTextStyles.caption(
                          size: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildOpenStatus(),
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
          size: 15,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          place.rating.toStringAsFixed(1),
          style: AppTextStyles.caption(
            size: 10,
            color: AppColors.text,
          ).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenStatus() {
    final bool open = place.isOpen;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: open
                ? Colors.greenAccent
                : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          open ? 'Open' : 'Closed',
          style: AppTextStyles.caption(
            size: 10,
            color: open
                ? Colors.green.shade700
                : Colors.red.shade700,
          ).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.30,
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
          const Icon(
            Icons.auto_awesome_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'For You',
            style: AppTextStyles.caption(
              size: 9,
              color: Colors.white,
            ).copyWith(
              fontWeight: FontWeight.w700,
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
}