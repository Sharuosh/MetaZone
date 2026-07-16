// File: lib/screens/ar/scene_builder/panels/left_assets_panel.dart
// MetaZone – AR Scene Builder: Left Assets Panel (Design Only – Ultra PRO)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class LeftAssetsPanel extends StatefulWidget {
  const LeftAssetsPanel({super.key});

  @override
  State<LeftAssetsPanel> createState() => _LeftAssetsPanelState();
}

class _LeftAssetsPanelState extends State<LeftAssetsPanel>
    with TickerProviderStateMixin {

  final List<String> tabs = [
    "Models",
    "Effects",
    "Portals",
    "Prefabs",
    "Favorites"
  ];

  int selectedTab = 0;

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
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          _searchBar(),
          const SizedBox(height: 8),
          _tabsBar(),
          const SizedBox(height: 8),
          Expanded(child: _assetsGrid()),
        ],
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
        "Assets Library",
        style: AppTextStyles.title(size: 18),
      ),
    );
  }

  // =============================================================
  // SEARCH BAR
  // =============================================================
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(.3)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Icon(Icons.search, color: AppColors.textSoft, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: AppTextStyles.body().copyWith(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: "Search assets...",
                  hintStyle: AppTextStyles.caption(size: 12)
                      .copyWith(color: AppColors.textSoft),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // TABS BAR
  // =============================================================
  Widget _tabsBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == selectedTab;
          return GestureDetector(
            onTap: () {
              setState(() => selectedTab = i);
              _fadeCtrl.forward(from: 0);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: active ? AppColors.neonGradient : null,
                color: active
                    ? null
                    : AppColors.surface.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppColors.border.withOpacity(.3),
                ),
              ),
              child: Text(
                tabs[i],
                style: AppTextStyles.caption(size: 12).copyWith(
                  color: active ? Colors.black : AppColors.textSoft,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // =============================================================
  // ASSETS GRID (Design only)
  // =============================================================
  Widget _assetsGrid() {
    // fake assets for design preview
    final List<Map<String, String>> items = [
      {"name": "Neon Cube", "thumb": "https://picsum.photos/seed/a1/200"},
      {"name": "Portal Ring", "thumb": "https://picsum.photos/seed/a2/200"},
      {"name": "Sci-Fi Door", "thumb": "https://picsum.photos/seed/a3/200"},
      {"name": "Magic Tree", "thumb": "https://picsum.photos/seed/a4/200"},
      {"name": "Crystal Rock", "thumb": "https://picsum.photos/seed/a5/200"},
    ];

    return FadeTransition(
      opacity: _fadeCtrl,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: items.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .75,
        ),
        itemBuilder: (_, i) => _assetCard(items[i]),
      ),
    );
  }

  // =============================================================
  // ASSET CARD
  // =============================================================
  Widget _assetCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        // design only – logic later
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withOpacity(.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THUMBNAIL
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                item["thumb"]!,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // NAME
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                item["name"]!,
                style: AppTextStyles.body(size: 14)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
