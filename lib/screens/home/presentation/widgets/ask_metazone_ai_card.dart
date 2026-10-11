import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';

class AskMetaZoneAiCard extends StatelessWidget {
  final VoidCallback? onTap;

  const AskMetaZoneAiCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        splashColor: Colors.white.withValues(
          alpha: 0.08,
        ),
        highlightColor: Colors.white.withValues(
          alpha: 0.04,
        ),
        child: Ink(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.20,
                ),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              _buildDecorations(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -35,
              right: -20,
              child: _buildGlow(
                size: 125,
                opacity: 0.12,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -25,
              child: _buildGlow(
                size: 135,
                opacity: 0.08,
              ),
            ),
            Positioned(
              top: 24,
              right: 78,
              child: _buildDot(
                size: 5,
                opacity: 0.35,
              ),
            ),
            Positioned(
              top: 52,
              right: 42,
              child: _buildDot(
                size: 3,
                opacity: 0.28,
              ),
            ),
            Positioned(
              bottom: 24,
              right: 105,
              child: _buildDot(
                size: 4,
                opacity: 0.22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(
          alpha: opacity,
        ),
      ),
    );
  }

  Widget _buildDot({
    required double size,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(
          alpha: opacity,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        18,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTextContent(),
          ),
          const SizedBox(width: 14),
          _buildAiButton(),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.14,
                ),
                borderRadius:
                BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.16,
                  ),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'MetaZone AI',
              style: AppTextStyles.body(
                size: 14,
                color: Colors.white,
              ).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          'Ask me anything about your world.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.heading(
            size: 19,
            color: Colors.white,
          ).copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Places, services, events and what to do next.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmallStyle(
            size: 11,
            color: Colors.white.withValues(
              alpha: 0.82,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiButton() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.14,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.22,
          ),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}