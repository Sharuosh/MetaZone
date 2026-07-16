// File: lib/screens/ar/scene_builder/panels/right_tools_panel.dart
// MetaZone – AR Scene Builder: Right Tools Panel (Design Only – Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class RightToolsPanel extends StatefulWidget {
  const RightToolsPanel({super.key});

  @override
  State<RightToolsPanel> createState() => _RightToolsPanelState();
}

class _RightToolsPanelState extends State<RightToolsPanel>
    with TickerProviderStateMixin {

  int selectedTool = 0;

  final List<Map<String, dynamic>> tools = [
    {"icon": Icons.open_with_rounded, "name": "Move"},
    {"icon": Icons.rotate_90_degrees_ccw_rounded, "name": "Rotate"},
    {"icon": Icons.transform_rounded, "name": "Scale"},
    {"icon": Icons.flip, "name": "Flip"},
    {"icon": Icons.copy_rounded, "name": "Duplicate"},
    {"icon": Icons.delete_outline_rounded, "name": "Delete", "danger": true},
    {"icon": Icons.straighten_rounded, "name": "Snap"},
    {"icon": Icons.align_vertical_center_rounded, "name": "Align"},
    {"icon": Icons.light_mode_rounded, "name": "Light"},
    {"icon": Icons.auto_awesome_rounded, "name": "FX"},
  ];

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
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: FadeTransition(
        opacity: _fadeCtrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            Expanded(child: _toolsList()),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // HEADER
  // =============================================================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        "Tools",
        style: AppTextStyles.title(size: 18),
      ),
    );
  }

  // =============================================================
  // TOOLS LIST
  // =============================================================
  Widget _toolsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: tools.length,
      itemBuilder: (_, i) => _toolButton(i),
    );
  }

  // =============================================================
  // TOOL BUTTON (Animated)
  // =============================================================
  Widget _toolButton(int index) {
    final item = tools[index];
    final bool active = selectedTool == index;
    final bool danger = item["danger"] == true;

    return GestureDetector(
      onTap: () {
        setState(() => selectedTool = index);
        // (Design only) Logic later
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? AppColors.neonGradient : null,
          color: active
              ? null
              : AppColors.surface.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: danger
                ? Colors.red.withOpacity(.6)
                : active
                ? Colors.transparent
                : AppColors.border.withOpacity(.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item["icon"],
              color: danger
                  ? Colors.redAccent
                  : active
                  ? Colors.black
                  : AppColors.textSoft,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              item["name"],
              style: AppTextStyles.body(size: 14).copyWith(
                color: danger
                    ? Colors.redAccent
                    : active
                    ? Colors.black
                    : AppColors.text,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
