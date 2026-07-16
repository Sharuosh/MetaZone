// File: lib/widgets/ar_super_menu.dart
// Central AR Super Menu — opens as modal bottom sheet
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'ar_super_menu_item.dart';

// Screens (adjust imports if your file paths differ)
import '../screens/ar/scene_builder/ar_scene_builder_screen.dart';
import '../screens/ar/portal_editor/portal_editor_screen.dart';
import '../screens/ar/object_editor/ar_object_editor_screen.dart';
import '../screens/ar/scene_builder/scene_library/scene_library_screen.dart';
import '../screens/ar/scene_builder/publish_scene/publish_drafts_screen.dart';
import '../screens/wallet/wallet_home_screen.dart';
import '../screens/marketplace/home.dart';
import '../screens/home/live_ar_feed_screen.dart';
import '../screens/home/modules/teleport_rooms_module.dart';

class ARSuperMenu {
  /// Use this to show the menu:
  /// ARSuperMenu.show(context);
  static void show(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return const _ARSuperMenuBody();
      },
    );
  }
}

class _ARSuperMenuBody extends StatelessWidget {
  const _ARSuperMenuBody({super.key});

  void _nav(BuildContext context, Widget Function() builder) {
    Navigator.of(context).pop(); // close sheet
    try {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => builder()));
    } catch (e) {
      // fallback snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to open screen: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double handleTopSpacing = 12;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 18, right: 18, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(.24),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text("Creator Hub", style: AppTextStyles.title(size: 18)),
                const Spacer(),
                Text("PRO Tools", style: AppTextStyles.caption().copyWith(color: AppColors.textSoft)),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of items (2 rows x 5 columns max, scroll if needed)
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              children: [
                ARSuperMenuItem(
                  icon: Icons.edit,
                  label: "Scene Builder",
                  onTap: () => _nav(context, () => const ARSceneBuilderScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.vrpano,
                  label: "Portal Studio",
                  onTap: () => _nav(context, () => const ARPortalEditorScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.threed_rotation,
                  label: "Object Editor",
                  onTap: () => _nav(context, () => const ARObjectEditorScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.photo_library_rounded,
                  label: "My Library",
                  onTap: () => _nav(context, () => const SceneLibraryScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.upload_file,
                  label: "Drafts / Publish",
                  onTap: () => _nav(context, () => const PublishDraftsScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.play_circle_fill_rounded,
                  label: "Preview Scene",
                  onTap: () => _nav(context, () => const SceneLibraryScreen()), // fallback to library preview
                ),

                ARSuperMenuItem(
                  icon: Icons.account_balance_wallet,
                  label: "Wallet",
                  onTap: () => _nav(context, () => const WalletHomeScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.storefront,
                  label: "Marketplace",
                  onTap: () => _nav(context, () => MarketplaceHomeScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.live_tv,
                  label: "Live AR Feed",
                  onTap: () => _nav(context, () => const LiveARFeedScreen()),
                ),

                ARSuperMenuItem(
                  icon: Icons.meeting_room,
                  label: "Teleport Rooms",
                  onTap: () => _nav(context, () => const TeleportRoomsScreen()),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // bottom action row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border.withOpacity(.3)),
                      ),
                      child: Text("Close", style: AppTextStyles.title(size: 15)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Quick create: open Scene Builder immediately
                      _nav(context, () => const ARSceneBuilderScreen());
                    },
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.neonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("Create New", style: AppTextStyles.title(size: 15).copyWith(color: Colors.black)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
