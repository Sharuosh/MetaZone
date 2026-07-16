// File: assets_panel.dart
// MetaZone – Assets Panel (Ultra PRO Edition)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import 'widgets/category_tab.dart';
import 'widgets/asset_item_card.dart';

class AssetsPanel extends StatefulWidget {
  final Function(String assetId) onAddAsset;

  const AssetsPanel({
    super.key,
    required this.onAddAsset,
  });

  @override
  State<AssetsPanel> createState() => _AssetsPanelState();
}

class _AssetsPanelState extends State<AssetsPanel>
    with TickerProviderStateMixin {
  int _selectedTab = 0;

  List<String> tabs = [
    "3D Models",
    "FX",
    "Lights",
    "Portals",
    "Templates",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(.3)),
      ),
      child: Column(
        children: [
          _headerSection(),
          _tabsSection(),
          const SizedBox(height: 10),
          Expanded(child: _assetsGrid()),
        ],
      ),
    );
  }

  // =============================================================
  // Header
  // =============================================================
  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text("Assets", style: AppTextStyles.title(size: 18)),
          const Spacer(),
          Icon(Icons.search, color: AppColors.textSoft),
        ],
      ),
    );
  }

  // =============================================================
  // Tabs
  // =============================================================
  Widget _tabsSection() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return CategoryTab(
            label: tabs[index],
            icon: Icons.folder,
            active: _selectedTab == index,
            onTap: () {
              setState(() => _selectedTab = index);
            },
          );
        },
      ),
    );
  }

  // =============================================================
  // Assets Grid
  // =============================================================
  Widget _assetsGrid() {
    // Fake demo data
    List<Map<String, dynamic>> assets = [
      {
        "id": "obj01",
        "name": "Sci-Fi Crate",
        "type": "3D Model",
        "thumb": "https://picsum.photos/seed/model1/200/200",
      },
      {
        "id": "light01",
        "name": "Warm Light",
        "type": "Light",
        "thumb": "https://picsum.photos/seed/light2/200/200",
      },
      {
        "id": "fx01",
        "name": "Hologram FX",
        "type": "Effect",
        "thumb": "https://picsum.photos/seed/fx5/200/200",
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: assets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, index) {
        final asset = assets[index];

        return AssetItemCard(
          name: asset["name"],
          type: asset["type"],
          imageUrl: asset["thumb"],
          onTap: () {},
          onAdd: () => widget.onAddAsset(asset["id"]),
        );
      },
    );
  }
}
