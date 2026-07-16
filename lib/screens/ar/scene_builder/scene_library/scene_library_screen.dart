// File: lib/screens/ar/scene_builder/scene_library/scene_library_screen.dart
// MetaZone – AR Scene Builder: Scene Library (Ultra PRO 2025)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/scene_thumbnail.dart';
import '../ar_scene_builder_screen.dart';

class SceneLibraryScreen extends StatefulWidget {
  const SceneLibraryScreen({super.key});

  @override
  State<SceneLibraryScreen> createState() => _SceneLibraryScreenState();
}

class _SceneLibraryScreenState extends State<SceneLibraryScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeCtrl;

  // Fake scenes for design preview
  List<Map<String, dynamic>> scenes = [
    {
      "title": "Cyber Hall Scene",
      "cover": "https://picsum.photos/seed/scene1/500",
      "updated": "2 days ago"
    },
    {
      "title": "Mystic Forest",
      "cover": "https://picsum.photos/seed/scene2/500",
      "updated": "3 hours ago"
    },
    {
      "title": "Neon City",
      "cover": "https://picsum.photos/seed/scene3/500",
      "updated": "just now"
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
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
                const SizedBox(height: 16),
                _searchBar(),
                const SizedBox(height: 20),
                _newSceneButton(),
                const SizedBox(height: 24),
                Text("Your Scenes",
                    style: AppTextStyles.title(size: 18)),
                const SizedBox(height: 12),
                Expanded(child: _gridScenes()),
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
              color: AppColors.card.withOpacity(.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Text("Scene Library", style: AppTextStyles.title(size: 22)),
        const Spacer(),
        Icon(Icons.settings, color: AppColors.textSoft),
      ],
    );
  }

  // =============================================================
  // SEARCH BAR
  // =============================================================
  Widget _searchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: AppColors.textSoft),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                hintText: "Search scenes...",
                hintStyle: AppTextStyles.caption(size: 12)
                    .copyWith(color: AppColors.textSoft),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // =============================================================
  // NEW SCENE BUTTON
  // =============================================================
  Widget _newSceneButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ARSceneBuilderScreen(),
          ),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          gradient: AppColors.neonGradient,
          borderRadius: BorderRadius.circular(20),
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
            const Icon(Icons.add_box_rounded,
                color: Colors.black, size: 50),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                "Create New Scene",
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
  // SCENES GRID
  // =============================================================
  Widget _gridScenes() {
    return GridView.builder(
      itemCount: scenes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) => _sceneCard(i),
    );
  }

  // =============================================================
  // SCENE CARD WITH ACTIONS
  // =============================================================
  Widget _sceneCard(int index) {
    final item = scenes[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ARSceneBuilderScreen()),
        );
      },
      child: Stack(
        children: [
          SceneThumbnail(
            title: item["title"],
            subtitle: "Updated: ${item["updated"]}",
            imageUrl: item["cover"],
            overlayIcon: const Icon(Icons.edit,
                size: 20, color: Colors.white70),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: _sceneActions(index, item),
          ),
        ],
      ),
    );
  }

  Widget _sceneActions(int index, Map<String, dynamic> item) {
    return Row(
      children: [
        _action("Dup", Icons.copy_rounded, () {
          setState(() {
            scenes.insert(index + 1, {
              "title": "${item["title"]} (copy)",
              "cover": item["cover"],
              "updated": "just now",
            });
          });
        }),
        const SizedBox(width: 8),
        _action("Delete", Icons.delete_outline_rounded, () {
          _confirmDelete(index);
        }, danger: true),
      ],
    );
  }

  Widget _action(String label, IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: danger
              ? Colors.red.withOpacity(.2)
              : AppColors.surface.withOpacity(.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: danger ? Colors.redAccent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color:
                danger ? Colors.redAccent : AppColors.textSoft),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption(size: 12).copyWith(
                color:
                danger ? Colors.redAccent : AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // CONFIRM DELETE
  // =============================================================
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title:
        Text("Delete Scene", style: AppTextStyles.title(size: 16)),
        content: Text(
          "Are you sure you want to delete this scene? This cannot be undone.",
          style: AppTextStyles.body(),
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: AppTextStyles.caption()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Delete",
                style: AppTextStyles.caption()
                    .copyWith(color: Colors.redAccent)),
            onPressed: () {
              setState(() => scenes.removeAt(index));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
