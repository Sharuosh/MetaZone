// File: lib/screens/ar/scene_builder/panels/top_scene_header.dart
// MetaZone – AR Scene Builder: Top Scene Header (Design Only – Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class TopSceneHeader extends StatefulWidget {
  const TopSceneHeader({super.key});

  @override
  State<TopSceneHeader> createState() => _TopSceneHeaderState();
}

class _TopSceneHeaderState extends State<TopSceneHeader>
    with TickerProviderStateMixin {

  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeCtrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            _backButton(),
            const SizedBox(width: 14),

            // TITLE
            Text(
              "AR Scene Builder",
              style: AppTextStyles.title(size: 22)
                  .copyWith(fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            // ACTION BUTTONS
            _circleButton(Icons.save_alt_rounded),
            const SizedBox(width: 12),
            _circleButton(Icons.camera_alt_rounded),
            const SizedBox(width: 12),
            _circleButton(Icons.settings_rounded),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // BACK BUTTON
  // =============================================================
  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(.35)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
      ),
    );
  }

  // =============================================================
  // ACTION BUTTONS (CIRCULAR)
  // =============================================================
  Widget _circleButton(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withOpacity(.35)),
      ),
      child: Icon(
        icon,
        color: AppColors.textSoft,
        size: 22,
      ),
    );
  }
}
