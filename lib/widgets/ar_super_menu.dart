import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import 'ar_super_menu_item.dart';

// Screens
import '../screens/ar/object_editor/ar_object_editor_screen.dart';
import '../screens/ar/portal_editor/portal_editor_screen.dart';
import '../screens/ar/scene_builder/ar_scene_builder_screen.dart';
import '../screens/ar/scene_builder/publish_scene/publish_drafts_screen.dart';
import '../screens/ar/scene_builder/scene_library/scene_library_screen.dart';

import '../screens/home/live_ar_feed_screen.dart';
import '../screens/home/modules/teleport_rooms_module.dart';

import '../screens/marketplace/home.dart';
import '../screens/wallet/wallet_home_screen.dart';

class ARSuperMenu {
  const ARSuperMenu._();

  static Future<void> show(
      BuildContext context,
      ) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ARSuperMenuBody(),
    );
  }
}

class _ARSuperMenuBody extends StatelessWidget {
  const _ARSuperMenuBody({super.key});

  void _nav(
      BuildContext context,
      Widget Function() builder,
      ) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => builder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Container(
            padding: AppSpacing.allXL,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  AppRadius.xxxl,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.card.withValues(
                  alpha: .24,
                ),
                borderRadius:
                AppRadius.circleRadius,
              ),
            ),

            AppSpacing.gapLG,

            Row(
              children: [
                Text(
                  'Creator Hub',
                  style:
                  AppTextStyles.title.copyWith(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),

                const Spacer(),

                Text(
                  'PRO Tools',
                  style:
                  AppTextStyles.caption
                      .copyWith(
                    color:
                    AppColors.textSoft,
                  ),
                ),
              ],
            ),

            AppSpacing.gapXL,

            GridView(
                physics:
                const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: .78,
                ),
                children: [                ARSuperMenuItem(
                  icon: Icons.edit,
                  label: 'Scene Builder',
                  onTap: () => _nav(
                    context,
                        () => const ARSceneBuilderScreen(),
                  ),
                ),

                  ARSuperMenuItem(
                    icon: Icons.vrpano,
                    label: 'Portal Studio',
                    onTap: () => _nav(
                      context,
                          () => const ARPortalEditorScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.threed_rotation,
                    label: 'Object Editor',
                    onTap: () => _nav(
                      context,
                          () => const ARObjectEditorScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.photo_library_rounded,
                    label: 'My Library',
                    onTap: () => _nav(
                      context,
                          () => const SceneLibraryScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.upload_file,
                    label: 'Drafts / Publish',
                    onTap: () => _nav(
                      context,
                          () => const PublishDraftsScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.play_circle_fill_rounded,
                    label: 'Preview Scene',
                    onTap: () => _nav(
                      context,
                          () => const SceneLibraryScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    onTap: () => _nav(
                      context,
                          () => const WalletHomeScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.storefront,
                    label: 'Marketplace',
                    onTap: () => _nav(
                      context,
                          () => MarketplaceHomeScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.live_tv,
                    label: 'Live AR Feed',
                    onTap: () => _nav(
                      context,
                          () => const LiveARFeedScreen(),
                    ),
                  ),

                  ARSuperMenuItem(
                    icon: Icons.meeting_room,
                    label: 'Teleport Rooms',
                    onTap: () => _nav(
                      context,
                          () => const TeleportRoomsScreen(),
                    ),
                  ),
                ],
            ),

                AppSpacing.gapXL,

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius:
                            AppRadius.lgRadius,
                            border: Border.all(
                              color: AppColors.border
                                  .withValues(
                                alpha: .30,
                              ),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style:
                            AppTextStyles.title
                                .copyWith(
                              fontSize: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.gapMD,

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _nav(
                            context,
                                () => const ARSceneBuilderScreen(),
                          );
                        },
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient:
                            AppColors.neonGradient,
                            borderRadius:
                            AppRadius.lgRadius,
                          ),
                          child: Text(
                            'Create New',
                            style:
                            AppTextStyles.title
                                .copyWith(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ),
    );
  }
}