// File: object_quick_actions_menu.dart
// MetaZone – Object Quick Actions Menu (Ultra PRO Edition • Fixed Compatibility)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'widgets/quick_action_button.dart';

class ObjectQuickActionsMenu extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onFocus;
  final VoidCallback onBringForward;
  final VoidCallback onSendBackward;
  final VoidCallback onLock;
  final VoidCallback onToggleGizmos;

  const ObjectQuickActionsMenu({
    super.key,
    required this.onDelete,
    required this.onDuplicate,
    required this.onFocus,
    required this.onBringForward,
    required this.onSendBackward,
    required this.onLock,
    required this.onToggleGizmos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarySoft.withOpacity(.4),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickActionButton(icon: Icons.center_focus_strong, label: "Focus", onTap: onFocus),
          QuickActionButton(icon: Icons.copy_rounded, label: "Dup", onTap: onDuplicate),
          QuickActionButton(icon: Icons.arrow_upward, label: "Front", onTap: onBringForward),
          QuickActionButton(icon: Icons.arrow_downward, label: "Back", onTap: onSendBackward),
          QuickActionButton(icon: Icons.lock_outline, label: "Lock", onTap: onLock),
          QuickActionButton(icon: Icons.grid_3x3, label: "Gizmos", onTap: onToggleGizmos),
          QuickActionButton(icon: Icons.delete_outline, label: "Del", onTap: onDelete, danger: true),
        ],
      ),
    );
  }
}
