import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

class CategoryItem extends StatelessWidget {
  final HomeCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: SizedBox(
        width: 88,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            highlightColor: AppColors.primary.withValues(
              alpha: 0.04,
            ),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.card,
                borderRadius:
                BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSoft.withValues(
                    alpha: 0.08,
                  ),
                  width: 1,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color:
                    AppColors.primary.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.035,
                    ),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  _buildIcon(),

                  const SizedBox(height: 8),

                  _buildLabel(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 180,
      ),
      curve: Curves.easeOutCubic,
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: selected
            ? Colors.white.withValues(alpha: 0.16)
            : AppColors.primary.withValues(
          alpha: 0.09,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedScale(
        scale: selected ? 1.04 : 1.0,
        duration: const Duration(
          milliseconds: 180,
        ),
        curve: Curves.easeOutBack,
        child: Icon(
          category.icon,
          size: 21,
          color: selected
              ? Colors.white
              : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      category.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTextStyles.caption(
        size: 11,
        color: selected
            ? Colors.white
            : AppColors.text,
      ).copyWith(
        fontWeight: selected
            ? FontWeight.w700
            : FontWeight.w500,
      ),
    );
  }
}