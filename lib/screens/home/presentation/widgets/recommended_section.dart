import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/presentation/widgets/recommended_place_card.dart';

class RecommendedSection extends StatelessWidget {
  final List<NearbyPlace> places;
  final VoidCallback? onSeeAll;
  final ValueChanged<NearbyPlace>? onPlaceTap;

  const RecommendedSection({
    super.key,
    required this.places,
    this.onSeeAll,
    this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildPlaces(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended for You',
                style: AppTextStyles.heading(
                  size: 20,
                  color: AppColors.text,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Places MetaZone thinks you may like',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmallStyle(
                  size: 12,
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),
        _buildSeeAllButton(),
      ],
    );
  }

  Widget _buildSeeAllButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSeeAll,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: AppTextStyles.bodySmallStyle(
                  size: 13,
                  color: AppColors.primary,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 3),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaces() {
    return SizedBox(
      height: 224,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          right: 2,
          bottom: 4,
        ),
        itemCount: places.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final NearbyPlace place = places[index];

          return RecommendedPlaceCard(
            place: place,
            onTap: () {
              onPlaceTap?.call(place);
            },
          );
        },
      ),
    );
  }
}