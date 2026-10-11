import 'package:flutter/material.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/home/presentation/widgets/goal_action_item.dart';

class WhatCanIDoSection extends StatelessWidget {
  final List<GoalAction> goals;
  final ValueChanged<GoalAction>? onGoalTap;

  const WhatCanIDoSection({
    super.key,
    required this.goals,
    this.onGoalTap,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildGoals(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Can I Do?',
          style: AppTextStyles.heading(
            size: 20,
            color: AppColors.text,
          ).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Tell MetaZone what you want to accomplish',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmallStyle(
            size: 12,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }

  Widget _buildGoals() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: goals.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.75,
      ),
      itemBuilder: (context, index) {
        final GoalAction goal = goals[index];

        return GoalActionItem(
          goal: goal,
          onTap: () {
            onGoalTap?.call(goal);
          },
        );
      },
    );
  }
}