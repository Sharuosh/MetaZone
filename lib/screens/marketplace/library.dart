import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _category = "All";
  String _query = "";

  final List<Map<String, dynamic>> _assets = [
    {
      "title": "Hologram Portal",
      "type": "Portal",
      "uses": 14,
      "icon": Icons.auto_awesome,
    },
    {
      "title": "Neon Sculpture",
      "type": "3D Object",
      "uses": 5,
      "icon": Icons.assistant_photo,
    },
    {
      "title": "AR Light Beam",
      "type": "Light",
      "uses": 8,
      "icon": Icons.light_mode,
    },
    {
      "title": "Cyber Sticker",
      "type": "Sticker",
      "uses": 3,
      "icon": Icons.wallpaper,
    },
  ];

  List<Map<String, dynamic>> get filteredAssets {
    return _assets.where((a) {
      final matchCategory = _category == "All" || a["type"] == _category;
      final matchQuery =
          _query.isEmpty || a["title"].toLowerCase().contains(_query.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("My Library", style: AppTextStyles.heading()),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
          )
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration.collapsed(
                          hintText: "Search your assets…"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔽 Filter Options
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip("All"),
                _filterChip("Portal"),
                _filterChip("3D Object"),
                _filterChip("Light"),
                _filterChip("Sticker"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🧱 ASSETS GRID
          Expanded(
            child: filteredAssets.isEmpty
                ? Center(
              child: Text("No assets found.",
                  style: AppTextStyles.caption(size: 14)),
            )
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: filteredAssets.length,
              itemBuilder: (_, i) => _assetCard(filteredAssets[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String name) {
    final active = _category == name;
    return GestureDetector(
      onTap: () => setState(() => _category = name),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(name,
            style: AppTextStyles.body(
                size: 13,
                color: active ? Colors.black : AppColors.textLight)),
      ),
    );
  }

  Widget _assetCard(Map<String, dynamic> a) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // icon
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(a["icon"], size: 38, color: AppColors.primary),
            ),
          ),

          const SizedBox(height: 12),

          Text(a["title"], style: AppTextStyles.title(size: 15)),
          const SizedBox(height: 4),
          Text(a["type"], style: AppTextStyles.caption(size: 12)),

          const Spacer(),

          Row(
            children: [
              Icon(Icons.auto_graph, size: 16, color: AppColors.textSoft),
              const SizedBox(width: 4),
              Text("${a["uses"]} uses", style: AppTextStyles.caption(size: 11)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: open AR preview
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Use AR",
                      style: TextStyle(color: Colors.black, fontSize: 12)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
