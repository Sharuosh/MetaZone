import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../spot_details/ar_spot_details_screen.dart';
import '../../create/ar_portal_viewer.dart';

class ARSpotsSearchTab extends StatefulWidget {
  final String query;
  const ARSpotsSearchTab({super.key, required this.query});

  @override
  State<ARSpotsSearchTab> createState() => _ARSpotsSearchTabState();
}

class _ARSpotsSearchTabState extends State<ARSpotsSearchTab> {
  final List<String> _filters = ["All", "Nearby", "Hot", "Featured"];
  String _activeFilter = "All";

  // MOCK DATA
  final List<Map<String, dynamic>> _allSpots = [
    {
      "id": "spot_01",
      "title": "Ancient Light Rock",
      "creator": "MetaUser",
      "type": "AR Spot",
      "distance": 150, // meters
      "likes": 220,
      "views": 6400,
      "hot": true,
      "featured": false,
      "icon": Icons.location_on,
      "color": 0xff8e44ad,
    },
    {
      "id": "spot_02",
      "title": "Floating Beacon",
      "creator": "Hadi",
      "type": "AR Spot",
      "distance": 900,
      "likes": 310,
      "views": 11200,
      "hot": false,
      "featured": true,
      "icon": Icons.explore,
      "color": 0xff1abc9c,
    },
    {
      "id": "spot_03",
      "title": "Crystal Energy Point",
      "creator": "Lina",
      "type": "Energy Node",
      "distance": 2100,
      "likes": 180,
      "views": 2200,
      "hot": false,
      "featured": false,
      "icon": Icons.bubble_chart,
      "color": 0xffe67e22,
    },
    {
      "id": "spot_04",
      "title": "Meta Shrine",
      "creator": "ARMaster",
      "type": "AR Spot",
      "distance": 9999, // remote
      "likes": 450,
      "views": 16400,
      "hot": true,
      "featured": true,
      "icon": Icons.auto_awesome,
      "color": 0xff3498db,
    },
  ];

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _results = List.from(_allSpots);
  }

  @override
  void didUpdateWidget(covariant ARSpotsSearchTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applySearch(widget.query);
  }

  // SEARCH
  void _applySearch(String q) {
    final s = q.toLowerCase().trim();

    if (s.isEmpty) {
      setState(() => _results = List.from(_allSpots));
      _applyFilter(_activeFilter);
      return;
    }

    _results = _allSpots.where((spot) {
      return spot["title"].toLowerCase().contains(s) ||
          spot["creator"].toLowerCase().contains(s);
    }).toList();

    _applyFilter(_activeFilter);
  }

  // FILTER
  void _applyFilter(String f) {
    _activeFilter = f;
    List<Map<String, dynamic>> d = List.from(_results);

    switch (f) {
      case "Nearby":
        d.removeWhere((s) => (s["distance"] as int) > 1000);
        d.sort((a, b) => a["distance"].compareTo(b["distance"]));
        break;
      case "Hot":
        d = d.where((s) => s["hot"] == true).toList();
        break;
      case "Featured":
        d = d.where((s) => s["featured"] == true).toList();
        break;
    }

    setState(() => _results = d);
  }

  // OPEN SPOT DETAILS DIRECT (MetaZone Standard)
  void _openSpotDirect(Map<String, dynamic> s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARSpotDetailsScreen(spotId: s["id"]),
      ),
    );
  }

  // OPEN SHEET (Preview)
  void _openSheet(Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _previewSheet(p),
    );
  }

  Widget _previewSheet(Map<String, dynamic> p) {
    return Container(
      height: 430,
      padding: const EdgeInsets.all(16),
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
              height: 6,
              width: 55,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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

          const SizedBox(height: 10),
          Text("${p["type"]} • ${_distanceLabel(p["distance"])}",
              style: AppTextStyles.caption()),

          const SizedBox(height: 12),

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

          // ACTIONS
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
                  icon: const Icon(Icons.view_in_ar, color: Colors.black),
                  label: const Text("Enter AR"),
                ),
              ),
              const SizedBox(width: 10),

              OutlinedButton(
                onPressed: () {},
                child: Icon(Icons.bookmark_add_outlined,
                    color: AppColors.textLight),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Text("Created by ${p["creator"]}", style: AppTextStyles.caption()),

          const Spacer(),
        ],
      ),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // FILTERS
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

        const SizedBox(height: 12),

        // LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _results.length,
            itemBuilder: (_, i) {
              final s = _results[i];

              return GestureDetector(
                onTap: () => _openSheet(s),
                onLongPress: () => _openSpotDirect(s), // SHORTCUT
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
                          color: Color(s["color"]).withOpacity(.25),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(s["icon"],
                            size: 30, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s["title"], style: AppTextStyles.title()),
                            const SizedBox(height: 4),
                            Text(
                              "${s["type"]} • ${_distanceLabel(s["distance"])}",
                              style: AppTextStyles.caption(),
                            ),
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

  String _distanceLabel(int meters) {
    if (meters < 1000) return "${meters}m";
    if (meters > 5000) return "Remote";
    return "${(meters / 1000).toStringAsFixed(1)}km";
  }
}
