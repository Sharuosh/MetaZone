// File: category_selector.dart
// MetaZone — Scene Builder: Category Selector (2025 • FIXED FOR PublishSceneScreen)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String> onSelect;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categories.map((c) {
          return GestureDetector(
            onTap: () => onSelect(c),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(.4),
                ),
              ),
              child: Text(
                c,
                style: AppTextStyles.caption(size: 13),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
