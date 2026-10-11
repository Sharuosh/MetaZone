import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';

class GoalActionItem extends StatelessWidget {
  final GoalAction goal;
  final VoidCallback? onTap;

  const GoalActionItem({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${goal.title}. ${goal.subtitle}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: AppColors.primary.withValues(
            alpha: 0.07,
          ),
          highlightColor: AppColors.primary.withValues(
            alpha: 0.035,
          ),
          child: Ink(
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
                    alpha: 0.035,
                  ),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              child: Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildText(),
                  ),
                  const SizedBox(width: 6),
                  _buildArrow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        goal.icon,
        size: 21,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goal.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.body(
            size: 13,
            color: AppColors.text,
          ).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          goal.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption(
            size: 10,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.textSoft.withValues(
          alpha: 0.06,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 15,
        color: AppColors.textSoft,
      ),
    );
  }
}