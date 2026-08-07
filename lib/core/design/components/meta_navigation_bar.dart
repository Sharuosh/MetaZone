import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

class MetaNavigationBar extends StatelessWidget {
  const MetaNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.height = 74,
  });

  final int currentIndex;
  final List<MetaNavigationItem> items;
  final ValueChanged<int> onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: AppRadius.circleRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 24,
            sigmaY: 24,
          ),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .10),
              borderRadius: AppRadius.circleRadius,
              border: Border.all(
                color: AppColors.glassBorder,
              ),
              boxShadow: AppShadows.glass,
            ),
            child: Row(
              children: List.generate(
                items.length,
                    (index) {
                  final selected =
                      index == currentIndex;

                  final item = items[index];

                  return Expanded(
                    child: InkWell(
                      borderRadius:
                      AppRadius.circleRadius,
                      onTap: () => onTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 220,
                        ),
                        curve: Curves.easeOut,
                        margin:
                        const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                          AppRadius.circleRadius,
                          gradient: selected
                              ? AppColors
                              .primaryGradient
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color: selected
                                  ? Colors.white
                                  : AppColors
                                  .textSecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors
                                    .textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MetaNavigationItem {
  const MetaNavigationItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}