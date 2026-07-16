// File: privacy_selector.dart
// MetaZone — Privacy Selector (2025 • Compatible Version)

import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';

class PrivacySelector extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const PrivacySelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<PrivacySelector> createState() => _PrivacySelectorState();
}

class _PrivacySelectorState extends State<PrivacySelector> {
  late String current;

  final List<Map<String, dynamic>> options = [
    {
      "label": "Public",
      "icon": Icons.public,
      "description": "Anyone in MetaZone can view this scene.",
    },
    {
      "label": "Private",
      "icon": Icons.lock,
      "description": "Only you can view this scene.",
    },
    {
      "label": "Unlisted",
      "icon": Icons.visibility_off,
      "description": "Only users with a direct link can access it.",
    },
  ];

  @override
  void initState() {
    super.initState();
    current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map(_buildOption).toList(),
    );
  }

  // =============================================================
  // OPTION TILE
  // =============================================================
  Widget _buildOption(Map<String, dynamic> item) {
    final bool active = item["label"] == current;

    return GestureDetector(
      onTap: () {
        setState(() => current = item["label"]);
        widget.onSelect(current);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.neonGradient : null,
          color: active ? null : AppColors.surface.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.border.withOpacity(.35),
          ),
          boxShadow: active
              ? [
            BoxShadow(
              color: AppColors.primarySoft.withOpacity(.45),
              blurRadius: 16,
              spreadRadius: 1,
            )
          ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item["icon"],
              color: active ? Colors.black : AppColors.textSoft,
            ),
            const SizedBox(width: 14),

            // Label + Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["label"],
                    style: AppTextStyles.body(size: 14).copyWith(
                      color: active ? Colors.black : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["description"],
                    style: AppTextStyles.caption(size: 11).copyWith(
                      color: active ? Colors.black87 : AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              active ? Icons.check_circle : Icons.circle_outlined,
              color: active ? Colors.black : AppColors.textSoft,
            ),
          ],
        ),
      ),
    );
  }
}
