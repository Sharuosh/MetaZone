import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

class HappeningCard extends StatelessWidget {
  final Happening item;
  final VoidCallback? onTap;

  const HappeningCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${item.title}, ${item.placeName}',
      child: SizedBox(
        width: 270,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            splashColor: _accentColor.withValues(
              alpha: 0.06,
            ),
            highlightColor: _accentColor.withValues(
              alpha: 0.03,
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
                      alpha: 0.045,
                    ),
                    blurRadius: 18,
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
      height: 122,
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
                      alpha: 0.34,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: _buildTypeBadge(),
          ),

          if (item.distance.trim().isNotEmpty)
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
    final String imageUrl = item.imageUrl.trim();

    if (imageUrl.isEmpty) {
      return _buildFallbackImage();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) {
        return _buildFallbackImage();
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
            _buildFallbackImage(),
            Center(
              child: SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accentColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _accentColor.withValues(
              alpha: 0.82,
            ),
            AppColors.secondary.withValues(
              alpha: 0.78,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _typeIcon,
          size: 42,
          color: Colors.white.withValues(
            alpha: 0.92,
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
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body(
              size: 15,
              color: AppColors.text,
            ).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              Icon(
                Icons.place_outlined,
                size: 15,
                color: AppColors.textSoft,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.placeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmallStyle(
                    size: 12,
                    color: AppColors.textSoft,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              if (item.hasMeta)
                Expanded(
                  child: _buildMeta(),
                )
              else
                const Spacer(),

              if (item.distance.trim().isNotEmpty)
                _buildDistanceText(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Icon(
          _typeMetaIcon,
          size: 14,
          color: _accentColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            item.meta!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(
              size: 10,
              color: AppColors.textMuted,
            ).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.near_me_rounded,
          size: 13,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 3),
        Text(
          item.distance,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            size: 10,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge() {
    final String label = _typeLabel;

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
          Icon(
            _typeIcon,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            label,
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
            Icons.location_on_outlined,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            item.distance,
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

  String get _typeLabel {
    switch (item.type) {
      case HappeningType.event:
        return 'Event';

      case HappeningType.offer:
        return 'Offer';

      case HappeningType.activity:
        return 'Activity';
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case HappeningType.event:
        return Icons.event_rounded;

      case HappeningType.offer:
        return Icons.local_offer_rounded;

      case HappeningType.activity:
        return Icons.auto_awesome_rounded;
    }
  }

  IconData get _typeMetaIcon {
    switch (item.type) {
      case HappeningType.event:
        return Icons.schedule_rounded;

      case HappeningType.offer:
        return Icons.sell_outlined;

      case HappeningType.activity:
        return Icons.explore_outlined;
    }
  }

  Color get _accentColor {
    switch (item.type) {
      case HappeningType.event:
        return AppColors.primary;

      case HappeningType.offer:
        return Colors.orange;

      case HappeningType.activity:
        return Colors.cyan;
    }
  }
}