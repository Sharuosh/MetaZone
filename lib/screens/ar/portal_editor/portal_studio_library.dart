// File: lib/screens/ar/portal_editor/portal_studio_library.dart
// MetaZone – Portal Studio Library (Ultra PRO Edition 2025)
// إدارة مشاريع بوابات AR + قوالب جاهزة + حفظ وإعادة تحميل

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import 'portal_editor_screen.dart';

class PortalStudioLibraryScreen extends StatefulWidget {
  const PortalStudioLibraryScreen({super.key});

  @override
  State<PortalStudioLibraryScreen> createState() =>
      _PortalStudioLibraryScreenState();
}

class _PortalStudioLibraryScreenState extends State<PortalStudioLibraryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  // Fake Data (هيتغير لاحقًا لما نربط Firebase / Local Storage)
  List<Map<String, dynamic>> savedPortals = [
    {
      "name": "Neon Gate",
      "thumb": "https://picsum.photos/seed/portal1/400/300",
      "updated": "2 days ago"
    },
    {
      "name": "Ancient Desert Portal",
      "thumb": "https://picsum.photos/seed/portal2/400/300",
      "updated": "5 hours ago"
    },
    {
      "name": "Cyber Tunnel",
      "thumb": "https://picsum.photos/seed/portal3/400/300",
      "updated": "just now"
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
    AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeCtrl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 18),

                _createNewPortalButton(),
                const SizedBox(height: 22),

                Text("Your Portal Projects",
                    style: AppTextStyles.title(size: 18)),
                const SizedBox(height: 14),

                Expanded(child: _projectsGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================================================
  // TOP BAR
  // =============================================================
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Portal Studio", style: AppTextStyles.title(size: 22)),
        const Spacer(),
        IconButton(
          onPressed: () {
            // settings placeholder
          },
          icon: Icon(Icons.settings, color: AppColors.textSoft),
        ),
      ],
    );
  }

  // =============================================================
  // CREATE NEW PORTAL BUTTON (Main CTA)
  // =============================================================
  Widget _createNewPortalButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ARPortalEditorScreen()),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppColors.neonGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primarySoft,
              blurRadius: 22,
              spreadRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.add_box_rounded, color: Colors.black, size: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Create New Portal",
                style: AppTextStyles.title(size: 20)
                    .copyWith(color: Colors.black),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // PROJECTS GRID (Saved Portals)
  // =============================================================
  Widget _projectsGrid() {
    return GridView.builder(
      itemCount: savedPortals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, index) {
        final item = savedPortals[index];

        return GestureDetector(
          onTap: () {
            // TODO: Load portal data and open editor
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ARPortalEditorScreen(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card.withOpacity(.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(.3)),
            ),
            child: Column(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    item["thumb"],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item["name"],
                            style: AppTextStyles.title(size: 14)),
                        const SizedBox(height: 6),
                        Text("Updated: ${item["updated"]}",
                            style: AppTextStyles.caption(size: 12)),
                        const Spacer(),
                        Row(
                          children: [
                            _smallAction(
                                icon: Icons.open_in_new_rounded,
                                label: "Open",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ARPortalEditorScreen(),
                                    ),
                                  );
                                }),
                            const SizedBox(width: 8),
                            _smallAction(
                                icon: Icons.copy_rounded,
                                label: "Dup",
                                onTap: () {
                                  setState(() {
                                    savedPortals.insert(index + 1, {
                                      "name": "${item["name"]} (copy)",
                                      "thumb": item["thumb"],
                                      "updated": "just now"
                                    });
                                  });
                                }),
                            const SizedBox(width: 8),
                            _smallAction(
                                icon: Icons.delete_outline,
                                label: "Delete",
                                danger: true,
                                onTap: () {
                                  _confirmDelete(index);
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================================================
  // Small action pill used in grid items
  // =============================================================
  Widget _smallAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: danger
                ? AppColors.surface.withOpacity(.14)
                : AppColors.surface.withOpacity(.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: danger ? Colors.red.withOpacity(.6) : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: danger ? Colors.redAccent : AppColors.text),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.caption(size: 12)
                      .copyWith(color: danger ? Colors.redAccent : AppColors.text)),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================
  // Confirm delete dialog
  // =============================================================
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text("Delete Portal", style: AppTextStyles.title(size: 16)),
        content: Text("Are you sure you want to delete this portal? This action cannot be undone.",
            style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: AppTextStyles.caption()),
          ),
          TextButton(
            onPressed: () {
              setState(() => savedPortals.removeAt(index));
              Navigator.pop(context);
            },
            child: Text("Delete", style: AppTextStyles.caption().copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
