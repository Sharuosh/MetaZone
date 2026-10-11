import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/presentation/widgets/happening_card.dart';

class HappeningSection extends StatelessWidget {
  final List<Happening> items;
  final VoidCallback? onSeeAll;
  final ValueChanged<Happening>? onItemTap;

  const HappeningSection({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildItemsList(),
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
                "What's Happening",
                style: AppTextStyles.heading(
                  size: 20,
                  color: AppColors.text,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Events, offers and activities around you',
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

  Widget _buildItemsList() {
    return SizedBox(
      height: 218,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          right: 2,
          bottom: 4,
        ),
        itemCount: items.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final Happening item = items[index];

          return HappeningCard(
            item: item,
            onTap: () {
              onItemTap?.call(item);
            },
          );
        },
      ),
    );
  }
}