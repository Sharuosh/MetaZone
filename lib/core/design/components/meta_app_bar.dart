import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

class MetaAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const MetaAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.transparent = true,
  });

  final String title;

  final Widget? leading;

  final List<Widget>? actions;

  final bool centerTitle;

  final bool transparent;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      backgroundColor:
      transparent
          ? Colors.transparent
          : AppColors.surface,
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: leading,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottom,
      ),
    );
  }
}