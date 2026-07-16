import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../create/ar_portal_viewer.dart';

class PortalsSearchTab extends StatefulWidget {
  final String query;
  const PortalsSearchTab({super.key, required this.query});

  @override
  State<PortalsSearchTab> createState() => _PortalsSearchTabState();
}

class _PortalsSearchTabState extends State<PortalsSearchTab> {
  final List<String> _filters = ["All", "Nearby", "Featured", "Trending"];
  String _activeFilter = "All";

  // MOCK DATA
  final List<Map<String, dynamic>> _allPortals = [
    {
      "id": "portal_01",
      "title": "Nebula Portal",
      "creator": "MetaLina",
      "type": "AR Portal",
      "distance": 210, // meters
      "likes": 420,
      "views": 8200,
      "featured": true,
      "color": 0xff6a5acd,
      "icon": Icons.vrpano,
    },
    {
      "id": "portal_02",
      "title": "Crystal Gateway",
      "creator": "ARMaster",
      "type": "AR Portal",
      "distance": 1300,
      "likes": 260,
      "views": 3200,
      "featured": false,
      "color": 0xff0099cc,
      "icon": Icons.door_sliding,
    },
  ];

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List.from(_allPortals);
  }

  @override
  void didUpdateWidget(covariant PortalsSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applySearch(widget.query);
  }

  // SEARCH
  void _applySearch(String q) {
    final s = q.toLowerCase().trim();
    if (s.isEmpty) {
      setState(() => _results = List.from(_allPortals));
      _applyFilter(_activeFilter);
      return;
    }

    setState(() {
      _results = _allPortals.where((p) {
        return p["title"].toLowerCase().contains(s) ||
            p["creator"].toLowerCase().contains(s);
      }).toList();
    });

    _applyFilter(_activeFilter);
  }

  // FILTER
  void _applyFilter(String f) {
    _activeFilter = f;
    List<Map<String, dynamic>> d = List.from(_results);

    switch (f) {
      case "Nearby":
        d.sort((a, b) => a["distance"].compareTo(b["distance"]));
        d = d.where((p) => p["distance"] < 1000).toList();
        break;

      case "Featured":
        d = d.where((p) => p["featured"] == true).toList();
        break;

      case "Trending":
        d.sort((b, a) =>
            ((a["likes"] + (a["views"] ~/ 20)))
                .compareTo(b["likes"] + (b["views"] ~/ 20)));
        break;

      default:
        break;
    }

    setState(() => _results = d);
  }

  // PORTAL PREVIEW (Bottom Sheet)
  void _openPortal(Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _portalSheet(p),
    );
  }

  Widget _portalSheet(Map<String, dynamic> p) {
    return Container(
      height: 430,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  height: 5,
                  width: 60,
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(6)))),

          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(p["color"]).withOpacity(.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(p["icon"], size: 42, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(p["title"], style: AppTextStyles.title(size: 20)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text("${p["type"]} • ${_distanceLabel(p["distance"])}",
              style: AppTextStyles.caption()),

          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text("${p["likes"]}", style: AppTextStyles.caption()),
              const SizedBox(width: 16),
              Icon(Icons.visibility, color: AppColors.textLight, size: 18),
              const SizedBox(width: 6),
              Text("${p["views"]}", style: AppTextStyles.caption()),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ARPortalViewerScreen(
                          spotId: p["id"],
                          title: p["title"],
                          owner: p["creator"],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.vrpano, color: Colors.black),
                  label: const Text("Open Portal"),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {},
                child:
                Icon(Icons.bookmark_outline, color: AppColors.textLight),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Text("Created by ${p["creator"]}", style: AppTextStyles.caption()),
        ],
      ),
    );
  }

  // UI COMPONENTS
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FILTER CHIPS
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _activeFilter;

              return GestureDetector(
                onTap: () => _applyFilter(f),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    f,
                    style: active
                        ? AppTextStyles.body()
                        : AppTextStyles.caption(),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final p = _results[i];

              return GestureDetector(
                onTap: () => _openPortal(p),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(p["color"]).withOpacity(.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(p["icon"],
                            color: AppColors.primary, size: 32),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p["title"], style: AppTextStyles.title()),
                            const SizedBox(height: 4),
                            Text(
                                "${p["type"]} • ${_distanceLabel(p["distance"])}",
                                style: AppTextStyles.caption()),
                          ],
                        ),
                      ),

                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: AppColors.textSoft),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper
  String _distanceLabel(int meters) {
    if (meters < 1000) return "${meters}m";
    return "${(meters / 1000).toStringAsFixed(1)}km";
  }
}
